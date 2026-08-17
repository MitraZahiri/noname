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

class _HabitatShopSheet extends StatefulWidget {
  const _HabitatShopSheet({required this.controller, required this.isTurkish});

  final DailyGoalsController controller;
  final bool isTurkish;

  @override
  State<_HabitatShopSheet> createState() => _HabitatShopSheetState();
}

class _HabitatShopSheetState extends State<_HabitatShopSheet> {
  HabitatShopCategory _selectedCategory = HabitatShopCategory.all;

  DailyGoalsController get controller => widget.controller;

  bool get isTurkish => widget.isTurkish;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final visibleItems =
            HabitatShopItem.values.where((item) {
              if (_selectedCategory == HabitatShopCategory.all) {
                return true;
              }

              return controller.categoryFor(item) == _selectedCategory;
            }).toList();

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ShopHeader(controller: controller, isTurkish: isTurkish),

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
                      ? 'Eşyaları sırayla aç, koleksiyonunu büyüt ve habitatını düzenle.'
                      : 'Unlock items in order, grow your collection, and customize your habitat.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 16),

                _CollectionProgress(
                  controller: controller,
                  isTurkish: isTurkish,
                ),

                const SizedBox(height: 18),

                _CategoryFilters(
                  selectedCategory: _selectedCategory,
                  isTurkish: isTurkish,
                  onSelected: (category) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                ),

                const SizedBox(height: 18),

                if (visibleItems.isEmpty)
                  _EmptyCategory(isTurkish: isTurkish)
                else
                  for (var index = 0; index < visibleItems.length; index++) ...[
                    _ShopItemCard(
                      item: visibleItems[index],
                      controller: controller,
                      isTurkish: isTurkish,
                    ),

                    if (index != visibleItems.length - 1)
                      const SizedBox(height: 12),
                  ],

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

class _ShopHeader extends StatelessWidget {
  const _ShopHeader({required this.controller, required this.isTurkish});

  final DailyGoalsController controller;
  final bool isTurkish;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.storefront_rounded, size: 30),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            isTurkish ? 'Habitat Mağazası' : 'Habitat Shop',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),

        _ShopCoinBadge(coins: controller.coins),
      ],
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

class _CollectionProgress extends StatelessWidget {
  const _CollectionProgress({
    required this.controller,
    required this.isTurkish,
  });

  final DailyGoalsController controller;
  final bool isTurkish;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final total = HabitatShopItem.values.length;
    final owned = controller.ownedItemCount;

    final progress = total == 0 ? 0.0 : owned / total;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.collections_bookmark_rounded, size: 20),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  isTurkish ? 'Koleksiyon' : 'Collection',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),

              Text(
                '$owned / $total',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 10),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(value: progress, minHeight: 7),
          ),
        ],
      ),
    );
  }
}

class _CategoryFilters extends StatelessWidget {
  const _CategoryFilters({
    required this.selectedCategory,
    required this.isTurkish,
    required this.onSelected,
  });

  final HabitatShopCategory selectedCategory;
  final bool isTurkish;
  final ValueChanged<HabitatShopCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (
            var index = 0;
            index < HabitatShopCategory.values.length;
            index++
          ) ...[
            _CategoryChip(
              category: HabitatShopCategory.values[index],
              selected: selectedCategory == HabitatShopCategory.values[index],
              isTurkish: isTurkish,
              onSelected: onSelected,
            ),

            if (index != HabitatShopCategory.values.length - 1)
              const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.selected,
    required this.isTurkish,
    required this.onSelected,
  });

  final HabitatShopCategory category;
  final bool selected;
  final bool isTurkish;
  final ValueChanged<HabitatShopCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      onSelected: (_) {
        onSelected(category);
      },
      avatar: Icon(_iconForCategory(category), size: 17),
      label: Text(_labelForCategory(category)),
    );
  }

  IconData _iconForCategory(HabitatShopCategory category) {
    return switch (category) {
      HabitatShopCategory.all => Icons.grid_view_rounded,
      HabitatShopCategory.nature => Icons.local_florist_rounded,
      HabitatShopCategory.toys => Icons.toys_rounded,
      HabitatShopCategory.lighting => Icons.lightbulb_rounded,
      HabitatShopCategory.furniture => Icons.chair_rounded,
    };
  }

  String _labelForCategory(HabitatShopCategory category) {
    return switch (category) {
      HabitatShopCategory.all => isTurkish ? 'Tümü' : 'All',
      HabitatShopCategory.nature => isTurkish ? 'Doğa' : 'Nature',
      HabitatShopCategory.toys => isTurkish ? 'Oyuncak' : 'Toys',
      HabitatShopCategory.lighting => isTurkish ? 'Işık' : 'Lighting',
      HabitatShopCategory.furniture => isTurkish ? 'Mobilya' : 'Furniture',
    };
  }
}

class _ShopItemCard extends StatelessWidget {
  const _ShopItemCard({
    required this.item,
    required this.controller,
    required this.isTurkish,
  });

  final HabitatShopItem item;
  final DailyGoalsController controller;
  final bool isTurkish;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final price = controller.priceFor(item);
    final owned = controller.isOwned(item);
    final placed = controller.isPlaced(item);
    final unlocked = controller.isUnlocked(item);
    final affordable = controller.canAfford(item);
    final rarity = controller.rarityFor(item);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _ItemEmojiBox(
                  emoji: _emojiFor(item),
                  unlocked: unlocked,
                  placed: placed,
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
                              _titleFor(item),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),

                          const SizedBox(width: 8),

                          _RarityBadge(rarity: rarity, isTurkish: isTurkish),
                        ],
                      ),

                      const SizedBox(height: 5),

                      Text(
                        _descriptionFor(item),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 7),

                      if (!unlocked)
                        _LockedRequirement(
                          requiredItem: controller.requiredOwnedItemFor(item),
                          isTurkish: isTurkish,
                        )
                      else if (owned)
                        _OwnedStatus(placed: placed, isTurkish: isTurkish)
                      else if (!affordable)
                        Text(
                          isTurkish
                              ? '${price - controller.coins} coin daha gerekli'
                              : '${price - controller.coins} more coins needed',
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall?.copyWith(
                            color: colors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else
                        Text(
                          isTurkish
                              ? 'Satın almaya hazır'
                              : 'Ready to purchase',
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                _ShopItemActionButton(
                  owned: owned,
                  placed: placed,
                  unlocked: unlocked,
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

          if (!unlocked && !owned)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                  ),
                ),
                child: const Icon(Icons.lock_rounded, size: 17),
              ),
            ),
        ],
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
            ? '${_titleFor(item)} satın alındı ve habitatına yerleştirildi! 🎉'
            : '${_titleFor(item)} was purchased and placed in your habitat! 🎉',

      HabitatPurchaseResult.alreadyOwned =>
        isTurkish ? 'Bu eşyaya zaten sahipsin.' : 'You already own this item.',

      HabitatPurchaseResult.locked =>
        isTurkish
            ? 'Bu eşyanın kilidi henüz açılmadı.'
            : 'This item is still locked.',

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
            ? '${_titleFor(item)} habitatına yerleştirildi.'
            : '${_titleFor(item)} was placed in your habitat.',

      HabitatPlacementResult.removed =>
        isTurkish
            ? '${_titleFor(item)} habitattan kaldırıldı.'
            : '${_titleFor(item)} was removed from your habitat.',

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

  String _emojiFor(HabitatShopItem item) {
    return switch (item) {
      HabitatShopItem.plant => '🪴',
      HabitatShopItem.teddy => '🧸',
      HabitatShopItem.lamp => '💡',
      HabitatShopItem.bookshelf => '📚',
    };
  }

  String _titleFor(HabitatShopItem item) {
    return switch (item) {
      HabitatShopItem.plant => isTurkish ? 'Bitki' : 'Plant',

      HabitatShopItem.teddy => isTurkish ? 'Oyuncak Ayı' : 'Teddy Bear',

      HabitatShopItem.lamp => isTurkish ? 'Lamba' : 'Lamp',

      HabitatShopItem.bookshelf => isTurkish ? 'Kitaplık' : 'Bookshelf',
    };
  }

  String _descriptionFor(HabitatShopItem item) {
    return switch (item) {
      HabitatShopItem.plant =>
        isTurkish
            ? 'Habitatın içine biraz doğa ekler.'
            : 'Adds a little nature to the habitat.',

      HabitatShopItem.teddy =>
        isTurkish
            ? 'Mimo için sevimli bir oyuncak.'
            : 'A cute toy for your companion.',

      HabitatShopItem.lamp =>
        isTurkish
            ? 'Habitatı daha sıcak ve rahat gösterir.'
            : 'Makes the habitat feel warmer and cozier.',

      HabitatShopItem.bookshelf =>
        isTurkish
            ? 'Bilginin habitatta da bir yeri olsun.'
            : 'Give knowledge a place in the habitat.',
    };
  }
}

class _ItemEmojiBox extends StatelessWidget {
  const _ItemEmojiBox({
    required this.emoji,
    required this.unlocked,
    required this.placed,
  });

  final String emoji;
  final bool unlocked;
  final bool placed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 58,
      height: 58,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color:
            !unlocked
                ? colors.surfaceContainerHighest
                : placed
                ? colors.tertiaryContainer
                : colors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Opacity(
        opacity: unlocked ? 1 : 0.4,
        child: Text(emoji, style: const TextStyle(fontSize: 34)),
      ),
    );
  }
}

class _RarityBadge extends StatelessWidget {
  const _RarityBadge({required this.rarity, required this.isTurkish});

  final HabitatItemRarity rarity;
  final bool isTurkish;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final backgroundColor = switch (rarity) {
      HabitatItemRarity.common => colors.secondaryContainer,
      HabitatItemRarity.rare => colors.tertiaryContainer,
      HabitatItemRarity.epic => colors.primaryContainer,
    };

    final foregroundColor = switch (rarity) {
      HabitatItemRarity.common => colors.onSecondaryContainer,
      HabitatItemRarity.rare => colors.onTertiaryContainer,
      HabitatItemRarity.epic => colors.onPrimaryContainer,
    };

    final label = switch (rarity) {
      HabitatItemRarity.common => isTurkish ? 'Yaygın' : 'Common',

      HabitatItemRarity.rare => isTurkish ? 'Nadir' : 'Rare',

      HabitatItemRarity.epic => isTurkish ? 'Epik' : 'Epic',
    };

    final icon = switch (rarity) {
      HabitatItemRarity.common => Icons.circle_rounded,
      HabitatItemRarity.rare => Icons.star_rounded,
      HabitatItemRarity.epic => Icons.auto_awesome_rounded,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: foregroundColor),

          const SizedBox(width: 4),

          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedRequirement extends StatelessWidget {
  const _LockedRequirement({
    required this.requiredItem,
    required this.isTurkish,
  });

  final HabitatShopItem? requiredItem;
  final bool isTurkish;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final requiredName = _requiredName();

    return Row(
      children: [
        Icon(Icons.lock_rounded, size: 15, color: colors.onSurfaceVariant),

        const SizedBox(width: 5),

        Expanded(
          child: Text(
            requiredItem == null
                ? (isTurkish ? 'Kilitli' : 'Locked')
                : (isTurkish
                    ? 'Önce $requiredName satın al'
                    : 'Buy $requiredName first'),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _requiredName() {
    return switch (requiredItem) {
      HabitatShopItem.plant => isTurkish ? 'Bitki' : 'Plant',

      HabitatShopItem.teddy => isTurkish ? 'Oyuncak Ayı' : 'Teddy Bear',

      HabitatShopItem.lamp => isTurkish ? 'Lamba' : 'Lamp',

      HabitatShopItem.bookshelf => isTurkish ? 'Kitaplık' : 'Bookshelf',

      null => '',
    };
  }
}

class _OwnedStatus extends StatelessWidget {
  const _OwnedStatus({required this.placed, required this.isTurkish});

  final bool placed;
  final bool isTurkish;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          placed ? Icons.check_circle_rounded : Icons.inventory_2_rounded,
          size: 15,
          color: placed ? colors.primary : colors.onSurfaceVariant,
        ),

        const SizedBox(width: 5),

        Text(
          placed
              ? (isTurkish ? 'Habitatta kullanılıyor' : 'Placed in habitat')
              : (isTurkish ? 'Envanterde' : 'In inventory'),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: placed ? colors.primary : colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ShopItemActionButton extends StatelessWidget {
  const _ShopItemActionButton({
    required this.owned,
    required this.placed,
    required this.unlocked,
    required this.affordable,
    required this.price,
    required this.isTurkish,
    required this.onPressed,
  });

  final bool owned;
  final bool placed;
  final bool unlocked;
  final bool affordable;
  final int price;
  final bool isTurkish;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (owned) {
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

    if (!unlocked) {
      return FilledButton.tonalIcon(
        onPressed: null,
        icon: const Icon(Icons.lock_rounded, size: 17),
        label: Text(isTurkish ? 'Kilitli' : 'Locked'),
      );
    }

    return FilledButton.tonal(
      onPressed: affordable ? onPressed : null,
      child: Text('🪙 $price'),
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

class _EmptyCategory extends StatelessWidget {
  const _EmptyCategory({required this.isTurkish});

  final bool isTurkish;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 34,
            color: colors.onSurfaceVariant,
          ),

          const SizedBox(height: 8),

          Text(
            isTurkish
                ? 'Bu kategoride henüz eşya yok.'
                : 'There are no items in this category yet.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
