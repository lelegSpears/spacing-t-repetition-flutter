class RepetitionService {
  const RepetitionService._();

  // Regra inicial do MVP, baseada apenas no percentual de acertos.
  // Não é um algoritmo adaptativo validado cientificamente quem sabe algum dia.
  static int nextIntervalDays({
    required int correct,
    required int total,
  }) {
    if (total <= 0 || correct < 0 || correct > total) {
      throw ArgumentError('Pontuação inválida.');
    }

    final rate = correct / total;
    if (rate < .50) return 1;
    if (rate < .70) return 2;
    if (rate < .85) return 4;
    if (rate < .95) return 7;
    return 14;
  }
}