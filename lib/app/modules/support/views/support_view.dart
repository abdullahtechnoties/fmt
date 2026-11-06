import 'package:flutter/material.dart';
import 'package:fmt/app/modules/support/controllers/support_controller.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:fmt/widgets/inputfield.dart';
import 'package:fmt/widgets/main_btn.dart';
import 'package:fmt/widgets/shared_ui.dart';
import 'package:get/get.dart';

/// Tracked support entry: a live category dropdown, validated raise-a-
/// ticket form, and a "My tickets" button with the unread badge. Guests
/// get a login prompt — the form never renders for them.
class SupportView extends GetView<SupportController> {
  const SupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: SafeArea(
        child: Column(
          children: [
            CustomHeaderBar(
              showmenu: false,
              title: 'support.title'.trns(),
              onMenu: () {},
            ),
            Expanded(
              child: Obx(() => controller.isLoggedIn
                  ? _buildForm()
                  : _buildGuestPrompt()),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Logged-in form ───────────────────────────────────────────────────────

  Widget _buildForm() {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.loadCategories();
        await controller.refreshUnread();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        padding: EdgeInsets.symmetric(horizontal: R.w(20)),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: R.h(20)),
              _buildTicketsButton(),
              SizedBox(height: R.h(20)),
              _buildLabel('support.full_name'.trns()),
              InputField(
                controller: controller.nameController,
                hintText: 'support.full_name_hint'.trns(),
                borderRadius: 12,
                validator: controller.requiredValidator,
              ),
              SizedBox(height: R.h(20)),
              _buildLabel('support.email'.trns()),
              InputField(
                controller: controller.emailController,
                hintText: 'support.email_hint'.trns(),
                keyboardType: TextInputType.emailAddress,
                borderRadius: 12,
                validator: controller.emailValidator,
              ),
              SizedBox(height: R.h(20)),
              _buildLabel('support.ticket_category'.trns()),
              Obx(() {
                if (controller.isLoadingCategories.value) {
                  return _buildCategoryPlaceholder();
                }
                if (controller.loadError.value != null) {
                  return _buildCategoryError();
                }
                return DropdownInputField(
                  value:
                      controller.selectedCategoryName.value,
                  hintText:
                      'support.ticket_category_hint'.trns(),
                  items: controller.categories
                      .map((c) => c.name)
                      .toList(),
                  borderRadius: 12,
                  onChanged: (val) => controller
                      .selectedCategoryName.value = val,
                );
              }),
              SizedBox(height: R.h(20)),
              _buildLabel('support.subject'.trns()),
              InputField(
                controller: controller.subjectController,
                hintText: 'support.subject_hint'.trns(),
                borderRadius: 12,
                validator: controller.requiredValidator,
              ),
              SizedBox(height: R.h(20)),
              _buildLabel('support.describe_issue'.trns()),
              InputField(
                controller: controller.issueController,
                hintText: 'support.describe_issue_hint'.trns(),
                maxLines: 5,
                borderRadius: 12,
                validator: controller.requiredValidator,
              ),
              SizedBox(height: R.h(32)),
              Obx(() => MainBtn(
                    text: 'support.submit'.trns(),
                    color: AppColors.primary,
                    borderRadius: 12,
                    isLoading:
                        controller.isSubmitting.value,
                    onPressed: controller.isSubmitting.value
                        ? null
                        : controller.submitTicket,
                  )),
              SizedBox(height: R.h(40)),
            ],
          ),
        ),
      ),
    );
  }

  /// "My tickets" shortcut with the global unread badge.
  Widget _buildTicketsButton() {
    return Obx(() {
      final unread = controller.unreadCount.value;
      return OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: Size(double.infinity, R.h(52)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: AppColors.primary),
        ),
        onPressed: controller.goToTickets,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.confirmation_number_outlined,
                size: R.sp(20), color: AppColors.primary),
            SizedBox(width: R.w(8)),
            Text(
              'support.my_tickets'.trns(),
              style: TextStyle(
                fontSize: R.sp(15),
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            if (unread > 0) ...[
              SizedBox(width: R.w(8)),
              Container(
                constraints: const BoxConstraints(
                    minWidth: 22, minHeight: 22),
                padding:
                    const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(11),
                ),
                alignment: Alignment.center,
                child: Text(
                  unread > 99 ? '99+' : '$unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildCategoryPlaceholder() {
    return Container(
      height: R.h(52),
      decoration: BoxDecoration(
        color: AppColors.darkGrey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: R.w(16)),
      child: Text(
        'support.categories_loading'.trns(),
        style: TextStyle(
          fontSize: R.sp(14),
          color: AppColors.darkGrey.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Widget _buildCategoryError() {
    return InkWell(
      onTap: controller.loadCategories,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: R.h(52),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade300),
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: R.w(16)),
        child: Text(
          'support.categories_failed'.trns(),
          style: TextStyle(
            fontSize: R.sp(13),
            color: Colors.red.shade700,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // ─── Guest gate ───────────────────────────────────────────────────────────

  Widget _buildGuestPrompt() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: R.w(24)),
      child: Column(
        children: [
          SizedBox(height: R.h(80)),
          Icon(Icons.support_agent_outlined,
              size: R.sp(72), color: AppColors.primary),
          SizedBox(height: R.h(24)),
          Text(
            'support.login_title'.trns(),
            style: TextStyle(
              fontSize: R.sp(20),
              fontWeight: FontWeight.w800,
              color: AppColors.darkGrey,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: R.h(12)),
          Text(
            'support.login_prompt'.trns(),
            style: TextStyle(
              fontSize: R.sp(14),
              color:
                  AppColors.darkGrey.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: R.h(32)),
          MainBtn(
            text: 'auth.required_login'.trns(),
            color: AppColors.primary,
            borderRadius: 12,
            onPressed: controller.goToLogin,
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: R.h(8), left: R.w(4)),
      child: Text(
        text,
        style: TextStyle(
          fontSize: R.sp(14),
          fontWeight: FontWeight.w700,
          color: AppColors.darkGrey,
        ),
      ),
    );
  }
}
