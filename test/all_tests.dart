import 'data/models/cell_test.dart' as cell_test;
import 'data/models/position_test.dart' as position_test;
import 'data/models/game_grid_test.dart' as game_grid_test;
import 'data/services/game_engine_test.dart' as game_engine_test;
import 'data/services/grid_generator_test.dart' as grid_generator_test;
import 'data/repositories/game_repository_test.dart' as game_repository_test;

void main() {
  cell_test.main();
  position_test.main();
  game_grid_test.main();
  game_engine_test.main();
  grid_generator_test.main();
  game_repository_test.main();
} 