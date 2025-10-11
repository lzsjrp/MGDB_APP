import 'package:flutter/material.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final Color backgroundColor;
  final BorderRadius borderRadius;
  final List<BoxShadow> boxShadow;
  final TextStyle textStyle;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.onPrevious,
    this.onNext,
    required this.backgroundColor,
    required this.borderRadius,
    required this.boxShadow,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Align(
        alignment: Alignment.center,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
            boxShadow: boxShadow,
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
                style: textStyle,
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
