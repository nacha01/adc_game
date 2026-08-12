class GameImages {
  GameImages._();

  /// Flame의 images.loadAll()에서 사용하는 경로
  /// Flame은 기본적으로 assets/images/를 기준으로 불러옵니다.
  static const List<String> fruitFlamePaths = [
    'midori/midori_0.png',
    'midori/midori_1.png',
    'midori/midori_2.png',
    'midori/midori_3.png',
    'midori/midori_4.png',
    'midori/midori_5.png',
    'midori/midori_6.png',
    'midori/midori_7.png',
    'midori/midori_8.png',
    'midori/midori_9.png',
    'midori/midori_10.png',
  ];

  /// 등록된 미도리 이미지 개수
  static int get fruitCount => fruitFlamePaths.length;

  /// Flutter의 Image.asset()에서 사용하는 전체 경로
  static String fruitAsset(int index) {
    if (index < 0 || index >= fruitFlamePaths.length) {
      throw RangeError.range(
        index,
        0,
        fruitFlamePaths.length - 1,
        'index',
      );
    }

    return 'assets/images/${fruitFlamePaths[index]}';
  }
}