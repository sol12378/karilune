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
import '../../widgets/ad_thumbnail.dart';
import '../../widgets/ideal/consumer/feed_ad_card.dart';

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
    final maxStep = form.isEditMode ? 1 : 4;

    return Scaffold(
      appBar: AppBar(
        title: Text(form.isEditMode ? '広告編集' : '広告投稿'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Stepper(
          type: StepperType.vertical,
          currentStep: form.currentStep,
          physics: const NeverScrollableScrollPhysics(),
        onStepContinue: () async {
          final error = notifier.validateStep(form.currentStep);
          if (error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error)),
            );
            return;
          }

          if (form.currentStep < maxStep) {
            if (!form.isEditMode && form.currentStep == 3) {
              notifier.submitForReview();
            }
            notifier.setStep(form.currentStep + 1);
            return;
          }

          if (form.isEditMode) {
            notifier.submit();
            if (context.mounted) {
              context.go('/advertiser/home');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('広告を更新しました')),
              );
            }
            return;
          }

          final adId = notifier.completePayment();
          if (context.mounted) {
            context.go('/advertiser/ads/complete/$adId');
          }
        },
        onStepCancel: () {
          if (form.currentStep > 0) {
            notifier.setStep(form.currentStep - 1);
          }
        },
        controlsBuilder: (context, details) {
          final isPaymentStep = !form.isEditMode && form.currentStep == maxStep;
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
                        ? (form.isEditMode
                            ? '保存する'
                            : (isPaymentStep ? '支払う' : '次へ'))
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
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: selected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.shade300,
                              width: selected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: AdThumbnail(
                              assetPath: path,
                              width: 72,
                              height: 100,
                              borderRadius: 0,
                            ),
                          ),
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
                    child: AdThumbnail(
                      assetPath: form.thumbnailAssetPath,
                      width: double.infinity,
                      height: 160,
                      borderRadius: 0,
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
                  key: ValueKey('category-${form.editingAdId}-${form.category}'),
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
                  key: ValueKey('prefecture-${form.editingAdId}-${form.prefecture}'),
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
                const SizedBox(height: 16),
                ExpansionTile(
                  title: const Text('会員プレビュー'),
                  subtitle: const Text('会員フィードでの表示イメージ'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 320,
                          child: FeedAdCard(ad: form.toPreviewAd()),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!form.isEditMode)
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
                  key: ValueKey('days-${form.editingAdId}-${form.distributionDays}'),
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
              ],
            ),
          ),
          if (!form.isEditMode)
            Step(
              title: const Text('料金確認'),
              isActive: form.currentStep >= 3,
              state: form.currentStep > 3
                  ? StepState.complete
                  : StepState.indexed,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('会員サイトでの表示イメージ'),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 300,
                    width: 280,
                    child: AdCardConsumer(ad: form.toPreviewAd()),
                  ),
                  const SizedBox(height: 16),
                  const Text('料金内訳'),
                  const SizedBox(height: 8),
                  _PricingLine(
                    label: '基本配信料',
                    value: PricingCalculator.formatYen(
                      form.distributionDays * 1000,
                    ),
                  ),
                  if (form.hasSpotlightOption)
                    _PricingLine(
                      label: '注目オプション',
                      value: PricingCalculator.formatYen(
                        form.distributionDays * 100,
                      ),
                    ),
                  if (form.hasDistributionRequestNotification)
                    _PricingLine(
                      label: '配信依頼通知',
                      value: PricingCalculator.formatYen(3000),
                    ),
                  if (form.hasDistributionSettingNotification)
                    _PricingLine(
                      label: '配信設定通知',
                      value: PricingCalculator.formatYen(3000),
                    ),
                  const Divider(),
                  _PricingLine(
                    label: '合計',
                    value: PricingCalculator.formatYen(total),
                    bold: true,
                  ),
                ],
              ),
            ),
          if (!form.isEditMode)
            Step(
              title: const Text('モック決済'),
              isActive: form.currentStep >= 4,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'お支払い金額: ${PricingCalculator.formatYen(total)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'カード番号（デモ）',
                      hintText: '4242 4242 4242 4242',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: '有効期限（デモ）',
                      hintText: '12/28',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'デモ用のモック決済です。実際の課金は発生しません。',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
        ],
        ),
      ),
    );
  }
}

class _PricingLine extends StatelessWidget {
  const _PricingLine({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            )
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
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
