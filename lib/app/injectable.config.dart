// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../providers/api_config_provider.dart' as _i187;
import '../providers/connectivity_provider.dart' as _i517;
import '../providers/theme_provider.dart' as _i522;
import '../providers/user_provider.dart' as _i26;
import '../services/book_service.dart' as _i490;
import '../services/cache_manager.dart' as _i802;
import '../services/chapter_service.dart' as _i193;
import '../services/downloads_service.dart' as _i708;
import '../services/favorites_service.dart' as _i211;
import '../services/session_service.dart' as _i984;
import '../shared/preferences.dart' as _i76;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.factory<_i517.ConnectivityProvider>(() => _i517.ConnectivityProvider());
    gh.factory<_i26.UserProvider>(() => _i26.UserProvider());
    gh.factory<_i708.DownloadsService>(() => _i708.DownloadsService());
    gh.factory<_i76.AppPreferences>(() => _i76.AppPreferences());
    gh.factory<_i187.ApiConfigProvider>(
      () => _i187.ApiConfigProvider(gh<_i76.AppPreferences>()),
    );
    gh.factory<_i522.ThemeProvider>(
      () => _i522.ThemeProvider(gh<_i76.AppPreferences>()),
    );
    gh.factory<_i802.CacheManager>(
      () => _i802.CacheManager(gh<_i187.ApiConfigProvider>()),
    );
    gh.factory<_i984.SessionService>(
      () => _i984.SessionService(gh<_i187.ApiConfigProvider>()),
    );
    gh.factory<_i211.FavoritesService>(
      () => _i211.FavoritesService(
        gh<_i984.SessionService>(),
        gh<_i187.ApiConfigProvider>(),
        gh<_i517.ConnectivityProvider>(),
      ),
    );
    gh.factory<_i490.BookService>(
      () => _i490.BookService(
        gh<_i984.SessionService>(),
        gh<_i187.ApiConfigProvider>(),
        gh<_i802.CacheManager>(),
      ),
    );
    gh.factory<_i193.ChapterService>(
      () => _i193.ChapterService(
        gh<_i984.SessionService>(),
        gh<_i187.ApiConfigProvider>(),
        gh<_i802.CacheManager>(),
      ),
    );
    return this;
  }
}
