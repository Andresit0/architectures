part of '_widgets.lib.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        strokeWidth: 4.0,
        color: CustomConfigs.appColors.primary,
      ),
    );
  }
}
