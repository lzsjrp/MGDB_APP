import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../providers/api_config_provider.dart';
import 'injectable.config.dart';

final GetIt getIt = GetIt.instance;

@module
abstract class RegisterModule {
  @lazySingleton
  ApiConfigProvider get apiConfigProvider => ApiConfigProvider();
}

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
void configureDependencies() => getIt.init();
