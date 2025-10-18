import 'package:flutter/material.dart';

import '../../../../core/theme/widgets_themes/pagination_theme.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final paginationTheme = Theme.of(context).extension<PaginationThemeData>()!;
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Align(
        alignment: Alignment.center,
        child: Container(
          decoration: BoxDecoration(
            color: paginationTheme.backgroundColor,
            borderRadius: paginationTheme.borderRadius,
            boxShadow: paginationTheme.boxShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: currentPage > 1 ? onPrevious : null,
                child: const Text('Voltar'),
              ),
              const SizedBox(width: 20),
              Text(
                'Página $currentPage/$totalPages',
                style: paginationTheme.textStyle,
              ),
              const SizedBox(width: 20),
              TextButton(
                onPressed: currentPage < totalPages ? onNext : null,
                child: const Text('Próximo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
