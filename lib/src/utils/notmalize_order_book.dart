List<dynamic> normalizeOrderBook(List<dynamic> priceLevels) {
  const normalizeCount = 100;
  var needToAdd = normalizeCount - priceLevels.length;

  for (var i = 0; i < needToAdd; i++) {
    priceLevels.add(['0', '0']);
  }

  return priceLevels;
}
