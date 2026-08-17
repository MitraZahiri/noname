import 'package:flutter/material.dart';

import '../../application/daily_goals_controller.dart';

Future<void> showHabitatShopSheet({
  required BuildContext context,
  required DailyGoalsController controller,
  required bool isTurkish,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return _HabitatShopSheet(controller: controller, isTurkish: isTurkish);
    },
  );
}

class _HabitatShopSheet extends StatelessWidget {
  const _HabitatShopSheet({required this.controller, required this.isTurkish});

  final DailyGoalsController controller;
  final bool isTurkish;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.storefront_rounded, size: 30),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isTurkish ? 'Habitat Mağazası' : 'Habitat Shop',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    _ShopCoinBadge(coins: controller.coins),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  isTurkish
                      ? 'Coinlerini kullanarak habitatını kişiselleştir.'
                      : 'Use your coins to personalize the habitat.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 6),

                Text(
                  isTurkish
                      ? 'Satın aldığın eşyaları istediğin zaman yerleştirebilir veya kaldırabilirsin.'
                      : 'You can place or remove purchased items whenever you want.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 20),

                _ShopItemCard(
                  item: HabitatShopItem.plant,
                  emoji: '🪴',
                  title: isTurkish ? 'Bitki' : 'Plant',
                  description:
                      isTurkish
                          ? 'Habitatın içine biraz doğa ekler.'
                          : 'Adds a little nature to the habitat.',
                  controller: controller,
                  isTurkish: isTurkish,
                ),

                const SizedBox(height: 12),

                _ShopItemCard(
                  item: HabitatShopItem.teddy,
                  emoji: '🧸',
                  title: isTurkish ? 'Oyuncak Ayı' : 'Teddy Bear',
                  description:
                      isTurkish
                          ? 'Mimo için sevimli bir oyuncak.'
                          : 'A cute toy for your companion.',
                  controller: controller,
                  isTurkish: isTurkish,
                ),

                const SizedBox(height: 12),

                _ShopItemCard(
                  item: HabitatShopItem.lamp,
                  emoji: '💡',
                  title: isTurkish ? 'Lamba' : 'Lamp',
                  description:
                      isTurkish
                          ? 'Habitatı daha sıcak ve rahat gösterir.'
                          : 'Makes the habitat feel warmer and cozier.',
                  controller: controller,
                  isTurkish: isTurkish,
                ),

                const SizedBox(height: 12),

                _ShopItemCard(
                  item: HabitatShopItem.bookshelf,
                  emoji: '📚',
                  title: isTurkish ? 'Kitaplık' : 'Bookshelf',
                  description:
                      isTurkish
                          ? 'Bilginin habitatta da bir yeri olsun.'
                          : 'Give knowledge a place in the habitat.',
                  controller: controller,
                  isTurkish: isTurkish,
                ),

                if (controller.ownedItemCount > 0) ...[
                  const SizedBox(height: 20),

                  _InventorySummary(
                    controller: controller,
                    isTurkish: isTurkish,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ShopCoinBadge extends StatelessWidget {
  const _ShopCoinBadge({required this.coins});

  final int coins;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '🪙 $coins',
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ShopItemCard extends StatelessWidget {
  const _ShopItemCard({
    required this.item,
    required this.emoji,
    required this.title,
    required this.description,
    required this.controller,
    required this.isTurkish,
  });

  final HabitatShopItem item;
  final String emoji;
  final String title;
  final String description;
  final DailyGoalsController controller;
  final bool isTurkish;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final price = controller.priceFor(item);

    final owned = controller.isOwned(item);

    final placed = controller.isPlaced(item);

    final affordable = controller.canAfford(item);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color:
                    placed ? colors.tertiaryContainer : colors.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 34)),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),

                      if (owned)
                        Icon(
                          placed
                              ? Icons.check_circle_rounded
                              : Icons.inventory_2_rounded,
                          size: 18,
                          color:
                              placed ? colors.primary : colors.onSurfaceVariant,
                        ),
                    ],
                  ),

                  const SizedBox(height: 3),

                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),

                  if (owned) ...[
                    const SizedBox(height: 5),

                    Text(
                      placed
                          ? (isTurkish
                              ? 'Habitatta kullanılıyor'
                              : 'Placed in habitat')
                          : (isTurkish ? 'Envanterde' : 'In inventory'),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color:
                            placed ? colors.primary : colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ] else if (!affordable) ...[
                    const SizedBox(height: 5),

                    Text(
                      isTurkish
                          ? '${price - controller.coins} coin daha gerekli'
                          : '${price - controller.coins} more coins needed',
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: colors.error),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 10),

            _ShopItemActionButton(
              owned: owned,
              placed: placed,
              affordable: affordable,
              price: price,
              isTurkish: isTurkish,
              onPressed: () async {
                if (owned) {
                  await _togglePlacement(context);
                } else {
                  await _purchase(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _purchase(BuildContext context) async {
    final result = await controller.purchase(item);

    if (!context.mounted) {
      return;
    }

    final message = switch (result) {
      HabitatPurchaseResult.purchased =>
        isTurkish
            ? '$title satın alındı ve habitatına yerleştirildi! 🎉'
            : '$title was purchased and placed in your habitat! 🎉',

      HabitatPurchaseResult.alreadyOwned =>
        isTurkish ? 'Bu eşyaya zaten sahipsin.' : 'You already own this item.',

      HabitatPurchaseResult.insufficientCoins =>
        isTurkish ? 'Yeterli coinin yok.' : 'Not enough coins.',

      HabitatPurchaseResult.saveFailed =>
        isTurkish
            ? 'Satın alma kaydedilemedi.'
            : 'The purchase could not be saved.',
    };

    _showMessage(context, message);
  }

  Future<void> _togglePlacement(BuildContext context) async {
    final result = await controller.togglePlacement(item);

    if (!context.mounted) {
      return;
    }

    final message = switch (result) {
      HabitatPlacementResult.placed =>
        isTurkish
            ? '$title habitatına yerleştirildi.'
            : '$title was placed in your habitat.',

      HabitatPlacementResult.removed =>
        isTurkish
            ? '$title habitattan kaldırıldı.'
            : '$title was removed from your habitat.',

      HabitatPlacementResult.notOwned =>
        isTurkish
            ? 'Önce bu eşyayı satın almalısın.'
            : 'You need to buy this item first.',

      HabitatPlacementResult.saveFailed =>
        isTurkish
            ? 'Değişiklik kaydedilemedi.'
            : 'The change could not be saved.',
    };

    _showMessage(context, message);
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ShopItemActionButton extends StatelessWidget {
  const _ShopItemActionButton({
    required this.owned,
    required this.placed,
    required this.affordable,
    required this.price,
    required this.isTurkish,
    required this.onPressed,
  });

  final bool owned;
  final bool placed;
  final bool affordable;
  final int price;
  final bool isTurkish;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (!owned) {
      return FilledButton.tonal(
        onPressed: affordable ? onPressed : null,
        child: Text('🪙 $price'),
      );
    }

    if (placed) {
      return OutlinedButton(
        onPressed: onPressed,
        child: Text(isTurkish ? 'Kaldır' : 'Remove'),
      );
    }

    return FilledButton.tonal(
      onPressed: onPressed,
      child: Text(isTurkish ? 'Yerleştir' : 'Place'),
    );
  }
}

class _InventorySummary extends StatelessWidget {
  const _InventorySummary({required this.controller, required this.isTurkish});

  final DailyGoalsController controller;
  final bool isTurkish;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.inventory_2_rounded, size: 21),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              isTurkish
                  ? '${controller.ownedItemCount} eşyan var • '
                      '${controller.placedItemCount} tanesi habitatta'
                  : '${controller.ownedItemCount} items owned • '
                      '${controller.placedItemCount} placed',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
