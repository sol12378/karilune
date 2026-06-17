import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../mock_data/ads_mock.dart';
import '../../mock_data/categories_mock.dart';
import '../../models/ad_form_state.dart';
import '../../providers/ad_form_provider.dart';
import '../../utils/pricing_calculator.dart';
import '../../widgets/ad_card_consumer.dart';

class AdPostPage extends ConsumerWidget {
  const AdPostPage({super.key, this.adId});

  final String? adId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(adFormProvider);
    final notifier = ref.read(adFormProvider.notifier);
    final dateFormat = DateFormat('yyyy/MM/dd');
    final total = PricingCalculator.calculateTotal(
      distributionDays: form.distributionDays,
      hasSpotlightOption: form.hasSpotlightOption,
      hasDistributionRequestNotification:
          form.hasDistributionRequestNotification,
      hasDistributionSettingNotification:
          form.hasDistributionSettingNotification,
    );
    final maxStep = form.isEditMode ? 2 : 3;

    return Scaffold(
      appBar: AppBar(
        title: Text(form.isEditMode ? '広告編集' : '広告投稿'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stepper(
        currentStep: form.currentStep,
        onStepContinue: () async {
          final error = notifier.validateStep(form.currentStep);
          if (error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error)),
            );
            return;
          }

          if (form.currentStep < maxStep) {
            notifier.setStep(form.currentStep + 1);
            return;
          }

          if (!form.isEditMode) {
            final confirmed = await showConfirmDialog(
              context,
              title: '投稿の確認',
              message: 'この内容で広告を投稿しますか？',
              confirmLabel: '投稿する',
            );
            if (!confirmed) return;
          }

          notifier.submit();
          if (context.mounted) {
            context.go('/advertiser/home');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  form.isEditMode ? '広告を更新しました' : '広告を投稿しました',
                ),
              ),
            );
          }
        },
        onStepCancel: () {
          if (form.currentStep > 0) {
            notifier.setStep(form.currentStep - 1);
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                if (form.currentStep > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('戻る'),
                  ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: details.onStepContinue,
                  child: Text(
                    form.currentStep == maxStep
                        ? (form.isEditMode ? '保存する' : '投稿する')
                        : '次へ',
                  ),
                ),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('素材'),
            isActive: form.currentStep >= 0,
            state:
                form.currentStep > 0 ? StepState.complete : StepState.indexed,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('サムネイルを選択'),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: thumbnailAssetOptions.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final path = thumbnailAssetOptions[index];
                      final selected = form.thumbnailAssetPath == path;
                      return InkWell(
                        onTap: () => notifier.updateThumbnailAssetPath(path),
                        child: Container(
                          width: 72,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: selected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.shade300,
                              width: selected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.asset(path, fit: BoxFit.cover),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      form.thumbnailAssetPath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('内容'),
            isActive: form.currentStep >= 1,
            state:
                form.currentStep > 1 ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                TextFormField(
                  key: ValueKey('company-${form.editingAdId}'),
                  initialValue: form.companyName,
                  maxLength: 30,
                  decoration: const InputDecoration(
                    labelText: '店舗・会社名',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: notifier.updateCompanyName,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: ValueKey('catch-${form.editingAdId}'),
                  initialValue: form.catchCopy,
                  maxLength: 40,
                  decoration: const InputDecoration(
                    labelText: 'キャッチコピー',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: notifier.updateCatchCopy,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: ValueKey('pr-${form.editingAdId}'),
                  initialValue: form.prText,
                  maxLength: 1000,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'PR文',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  onChanged: notifier.updatePrText,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: form.category,
                  decoration: const InputDecoration(
                    labelText: 'カテゴリー',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final category in categories.skip(1))
                      DropdownMenuItem(
                        value: category.name,
                        child: Text(category.name),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) notifier.updateCategory(value);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: form.prefecture,
                  decoration: const InputDecoration(
                    labelText: '配信地域',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final prefecture in prefectures.skip(1))
                      DropdownMenuItem(
                        value: prefecture,
                        child: Text(prefecture),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) notifier.updatePrefecture(value);
                  },
                ),
              ],
            ),
          ),
          Step(
            title: const Text('配信設定'),
            isActive: form.currentStep >= 2,
            state: form.currentStep > 2 && !form.isEditMode
                ? StepState.complete
                : StepState.indexed,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (form.isEditMode)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: const Text(
                      '配信期間・料金・オプションは編集できません（配信内容のみ変更可能）',
                    ),
                  ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('配信開始日'),
                  subtitle: Text(
                    form.startDate != null
                        ? dateFormat.format(form.startDate!)
                        : '未設定',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: form.isEditMode
                        ? null
                        : () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: form.startDate ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              notifier.updateStartDate(picked);
                            }
                          },
                  ),
                ),
                DropdownButtonFormField<int>(
                  initialValue: form.distributionDays,
                  decoration: const InputDecoration(
                    labelText: '配信日数（1〜90日）',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (var days = 5; days <= 90; days += 5)
                      DropdownMenuItem(
                        value: days,
                        child: Text('$days日'),
                      ),
                  ],
                  onChanged: form.isEditMode
                      ? null
                      : (value) {
                          if (value != null) {
                            notifier.updateDistributionDays(value);
                          }
                        },
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('注目オプション（100円/日）'),
                  value: form.hasSpotlightOption,
                  onChanged: form.isEditMode
                      ? null
                      : (value) => notifier.toggleSpotlight(value ?? false),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('配信依頼通知（3,000円）'),
                  value: form.hasDistributionRequestNotification,
                  onChanged: form.isEditMode
                      ? null
                      : (value) =>
                          notifier.toggleDistributionRequest(value ?? false),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('配信設定通知（3,000円）'),
                  value: form.hasDistributionSettingNotification,
                  onChanged: form.isEditMode
                      ? null
                      : (value) =>
                          notifier.toggleDistributionSetting(value ?? false),
                ),
                const SizedBox(height: 12),
                Text(
                  '合計金額: ${PricingCalculator.formatYen(total)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          if (!form.isEditMode)
            Step(
              title: const Text('プレビュー'),
              isActive: form.currentStep >= 3,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('会員サイトでの表示イメージ'),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 300,
                    width: 280,
                    child: AdCardConsumer(
                      ad: form.toPreviewAd(),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'OK',
  String cancelLabel = 'キャンセル',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
