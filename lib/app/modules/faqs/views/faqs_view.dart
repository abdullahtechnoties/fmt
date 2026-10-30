import 'package:flutter/material.dart';
import 'package:fmt/widgets/shared_ui.dart';
import 'package:get/get.dart';
import '../../../../../utilities/colors.dart';

class FaqsView extends GetView {
  const FaqsView({super.key});
  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Column(
        children: [
          SizedBox(height: 20),
          CustomHeaderBar(
            title: 'FAQs',
            showmenu: false
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildExpansionTile(
                    title: 'What is FMT?',
                    subtitle: 'Learn about our app and services.',
                    content:
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                  ),
                  const SizedBox(height: 12),
                  _buildExpansionTile(
                    title: 'How do I place an order?',
                    subtitle: 'Steps to order through the app.',
                    content:
                        'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
                  ),
                  const SizedBox(height: 12),
                  _buildExpansionTile(
                    title: 'What payment methods are accepted?',
                    subtitle: 'Payment options available in the app.',
                    content:
                        'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',
                  ),
                  const SizedBox(height: 12),
                  _buildExpansionTile(
                    title: 'How can I contact customer support?',
                    subtitle: 'Ways to reach our support team.',
                    content:
                        'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                  ),
                  const SizedBox(height: 12),
                  _buildExpansionTile(
                    title: 'Can I track my order?',
                    subtitle: 'Tracking your delivery in real-time.',
                    content:
                        'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium.',
                  ),             
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionTile({
    required String title,
    required String subtitle,
    required String content,
    bool isSelectable = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.3)),
      ),

      child: ExpansionTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: AppColors.grey.withValues(alpha: 0.3),
          ),
        ),
        backgroundColor: AppColors.white,
        textColor: AppColors.black,
        collapsedIconColor: AppColors.primary,
        iconColor: AppColors.primary,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: AppColors.black),
        ),
        collapsedTextColor: AppColors.black,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                isSelectable
                    ? SelectableText(
                      content,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.black,
                        height: 1.5,
                      ),
                    )
                    : Text(
                      content,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.black,
                        height: 1.5,
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}