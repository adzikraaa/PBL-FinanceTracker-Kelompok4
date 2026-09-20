import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/currency_formatter.dart';

class CustomInputWidget extends StatelessWidget {
  final String label;
  final IconData icon;
  final String tooltipMessage;
  final String prefix;
  final String suffix;
  final TextEditingController controller;
  final bool readOnly;
  final ValueChanged<String>? onChanged;

  const CustomInputWidget({
    Key? key,
    required this.label,
    required this.icon,
    required this.tooltipMessage,
    required this.controller,
    this.prefix = 'Rp',
    this.suffix = '',
    this.readOnly = false,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label Row
        Row(
          children: [
            Icon(icon, color: const Color(0xFFE2E385), size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFE2E385),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: tooltipMessage,
              triggerMode: TooltipTriggerMode.tap,
              showDuration: const Duration(seconds: 3),
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2D22).withOpacity(0.95),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E385).withOpacity(0.3)),
              ),
              textStyle: const TextStyle(
                color: Color(0xFFE2E385),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              child: const Icon(
                Icons.help_outline,
                color: Color(0xFF6B7E72),
                size: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Input Field Container
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF132A1D),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2C4334).withOpacity(0.5)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              if (prefix.isNotEmpty) ...[
                Text(
                  prefix,
                  style: const TextStyle(
                    color: Color(0xFF6B7E72),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: TextField(
                  controller: controller,
                  readOnly: readOnly,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CurrencyInputFormatter(),
                  ],
                  onChanged: onChanged,
                  style: TextStyle(
                    color: readOnly ? const Color(0xFF6B7E72) : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (suffix.isNotEmpty) ...[
                const SizedBox(width: 12),
                Text(
                  suffix,
                  style: const TextStyle(
                    color: Color(0xFF6B7E72),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
