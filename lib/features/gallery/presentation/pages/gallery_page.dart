import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';
import 'package:photo_manager_app/features/gallery/domain/enums/file_filter.dart';
import 'package:photo_manager_app/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:photo_manager_app/features/gallery/presentation/bloc/gallery_event.dart';
import 'package:photo_manager_app/features/gallery/presentation/bloc/gallery_state.dart';
import 'package:photo_manager_app/features/gallery/presentation/widgets/files_grid.dart';
import 'package:photo_manager_app/features/gallery/presentation/widgets/filter_chips.dart';
import 'package:photo_manager_app/features/gallery/presentation/widgets/gallery_header.dart';

import '../widgets/pending_info_banner.dart';


class GalleryPage extends StatelessWidget {

  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GalleryHeader(),
      body: BlocConsumer<GalleryBloc, GalleryState>(
        listener: _handleStateChanges,
        builder: (context, state) {
          return Column(
            children: [
              _buildFilters(context, state),
              _buildPendingBanner(state),
              Expanded(child: _buildContent(context, state))
            ],
          );
        },
      )
    );
  }

  void _handleStateChanges(BuildContext context, GalleryState state) {
    // TODO: Implementar al final
    if (state is GalleryError) {}
  }

  Widget _buildFilters(BuildContext context, GalleryState state) {

    FileFilter currentFilter = FileFilter.all;

    if (state is GalleryLoading) {
      currentFilter = state.filter;
    } else if (state is GalleryLoaded) {
      currentFilter = state.filter;
    } else if (state is GalleryLoadingMore) {
      currentFilter = state.filter;
    }

    return FilterChips(
      selectedFilter: currentFilter,
      onFilterSelected: (filter) {
        context.read<GalleryBloc>().add(LoadGallery(filter: filter));
      },
    );
  }

  Widget _buildPendingBanner(GalleryState state) {

    int pendingCount = 0;

    if (state is GalleryLoaded) {
      pendingCount = state.pendingCount;
    } else if (state is GalleryLoadingMore) {
      pendingCount = state.pendingCount;
    }

    return PendingInfoBanner(pendingCount: pendingCount);
  }

  Widget _buildContent(BuildContext context, GalleryState state) {

    if (state is GalleryStarting) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<GalleryBloc>().add(const LoadGallery());
      });
      return const Center(child: CircularProgressIndicator());
    }

    if (state is GalleryLoading) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (state is GalleryLoaded) {
      return _buildGrid(context, state);
    }

    if (state is GalleryLoadingMore) {
      return _buildGrid(context, state);
    }

    if (state is GalleryError) {
      // TODO: Implementar después
      return const SizedBox.shrink();
    }

    return const SizedBox.shrink();
  }

  Widget _buildGrid(BuildContext context, dynamic state) {

    List<GalleryFile> files = [];
    bool hasNext = false;
    bool isLoadingMore = false;

    if (state is GalleryLoaded) {
      files = state.files;
      hasNext = state.hasNext;
      isLoadingMore = false;
    } else if (state is GalleryLoadingMore) {
      files = state.files;
      hasNext = true;
      isLoadingMore = true;
    }

    return FilesGrid(

      files: files,
      hasNext: hasNext,
      isLoadingMore: isLoadingMore,
      onLoadMore: () {
        context.read<GalleryBloc>().add(const LoadMoreFiles());
      },
      onRefresh: () {
        context.read<GalleryBloc>().add(const RefreshGallery());
      },
      onFileTap: (file) {
        // TODO: Implementar detalle de imagen/video
      },
    );
  }
}