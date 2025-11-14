import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/theme/theme.dart';
import '../../dashboard/presentation/widgets/app_sidebar.dart';

import '../controllers/settings_controller.dart';
import '../widgets/account_info_tab.dart';
import '../widgets/billing_tab_placeholder.dart';
import '../widgets/delete_tab.dart';
import '../widgets/save_bar.dart';

import '../../profile/data/datasources/profile_remote_data_source.dart';
import '../../profile/data/repositories/profile_repository_impl.dart';
import '../../profile/domain/usecases/get_profile.dart';
import '../../profile/domain/usecases/update_profile.dart';
import '../../profile/domain/usecases/delete_profile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final SettingsController _controller;
  late final http.Client _httpClient;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _httpClient = http.Client();
    final remote = ProfileRemoteDataSourceImpl(_httpClient);
    final repo = ProfileRepositoryImpl(remote);

    _controller = SettingsController(
      getProfileUC: GetProfile(repo),
      updateProfileUC: UpdateProfile(repo),
      deleteProfileUC: DeleteProfile(repo),
    );

    _controller.load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    _httpClient.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    final content = AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(
              child: _controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        AccountInfoTab(controller: _controller),
                        const BillingTabPlaceholder(),
                        DeleteTab(controller: _controller),
                      ],
                    ),
            ),
            SaveBar(
              isSavingListenable: _controller,
              hasChangesListenable: _controller,
              onPressed: _controller.save,
            ),
          ],
        );
      },
    );

    return isMobile
        ? Scaffold(
            appBar: AppBar(
              title: const Text('Configuración'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            drawer: const Drawer(child: AppSidebar()),
            body: content,
            backgroundColor: AppColors.background,
          )
        : Scaffold(
            body: Row(
              children: [
                const AppSidebar(),
                Expanded(
                  child: Container(
                    color: AppColors.background,
                    child: content,
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingXLarge,
        vertical: AppDimensions.paddingLarge,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.centerLeft,
      child: Text('Configuración', style: AppTextStyles.h2),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        tabs: const [
          Tab(text: 'Información de la cuenta'),
          Tab(text: 'Facturación'),
          Tab(text: 'Eliminar cuenta'),
        ],
      ),
    );
  }
}
