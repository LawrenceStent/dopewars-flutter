import 'package:flutter/material.dart';

import '../../core/utils/responsive_layout.dart';

/// Custom responsive app bar for the game.
class GameAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  const GameAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.grey[900],
      elevation: 4,
      leading: leading,
      title: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveLayout.responsiveFontSize(
            context,
            mobile: 20,
            tablet: 24,
            desktop: 28,
          ),
          fontWeight: FontWeight.bold,
          color: Colors.amber[400],
        ),
      ),
      actions: actions,
      centerTitle: true,
      toolbarHeight: 60,
      shadowColor: Colors.black.withValues(alpha: 0.5),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

/// Custom error state widget.
class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(
            ResponsiveLayout.responsivePadding(context),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: ResponsiveLayout.responsiveIconSize(
                  context,
                  mobile: 48,
                  tablet: 64,
                  desktop: 80,
                ),
                color: Colors.red[400],
              ),
              SizedBox(
                height: ResponsiveLayout.responsiveGap(context, mobile: 16, tablet: 20, desktop: 24),
              ),
              Text(
                'Error',
                style: TextStyle(
                  fontSize: ResponsiveLayout.responsiveFontSize(
                    context,
                    mobile: 18,
                    tablet: 22,
                    desktop: 26,
                  ),
                  fontWeight: FontWeight.bold,
                  color: Colors.red[400],
                ),
              ),
              SizedBox(
                height: ResponsiveLayout.responsiveGap(context, mobile: 8, tablet: 12, desktop: 16),
              ),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ResponsiveLayout.responsiveFontSize(
                    context,
                    mobile: 14,
                    tablet: 16,
                    desktop: 18,
                  ),
                  color: Colors.grey[400],
                ),
              ),
              if (onRetry != null) ...[
                SizedBox(
                  height: ResponsiveLayout.responsiveGap(context, mobile: 16, tablet: 20, desktop: 24),
                ),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('RETRY'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[400],
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveLayout.responsivePadding(context, mobile: 24, tablet: 32, desktop: 40),
                      vertical: ResponsiveLayout.paddingMd,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom loading state widget.
class LoadingStateWidget extends StatelessWidget {
  final String? message;

  const LoadingStateWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Colors.amber[400],
            strokeWidth: 3,
          ),
          if (message != null) ...[
            SizedBox(height: ResponsiveLayout.responsiveGap(context, mobile: 16, tablet: 20, desktop: 24)),
            Text(
              message!,
              style: TextStyle(
                fontSize: ResponsiveLayout.responsiveFontSize(context),
                color: Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Custom empty state widget.
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(ResponsiveLayout.responsivePadding(context)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: ResponsiveLayout.responsiveIconSize(
                  context,
                  mobile: 48,
                  tablet: 64,
                  desktop: 80,
                ),
                color: Colors.grey[600],
              ),
              SizedBox(height: ResponsiveLayout.responsiveGap(context, mobile: 16, tablet: 20, desktop: 24)),
              Text(
                title,
                style: TextStyle(
                  fontSize: ResponsiveLayout.responsiveFontSize(
                    context,
                    mobile: 18,
                    tablet: 22,
                    desktop: 26,
                  ),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: ResponsiveLayout.responsiveGap(context, mobile: 8, tablet: 12, desktop: 16)),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: ResponsiveLayout.responsiveFontSize(context),
                    color: Colors.grey[400],
                  ),
                ),
              ],
              if (onAction != null && actionLabel != null) ...[
                SizedBox(height: ResponsiveLayout.responsiveGap(context, mobile: 16, tablet: 20, desktop: 24)),
                ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[400],
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveLayout.responsivePadding(context, mobile: 24, tablet: 32, desktop: 40),
                      vertical: ResponsiveLayout.paddingMd,
                    ),
                  ),
                  child: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
