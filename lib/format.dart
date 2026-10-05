/// intl paketine bağımlı olmamak için küçük Türkçe tarih yardımcıları.
const _months = [
  'Ocak',
  'Şubat',
  'Mart',
  'Nisan',
  'Mayıs',
  'Haziran',
  'Temmuz',
  'Ağustos',
  'Eylül',
  'Ekim',
  'Kasım',
  'Aralık',
];
const _shortMonths = [
  'Oca',
  'Şub',
  'Mar',
  'Nis',
  'May',
  'Haz',
  'Tem',
  'Ağu',
  'Eyl',
  'Eki',
  'Kas',
  'Ara',
];
const _days = [
  'Pazartesi',
  'Salı',
  'Çarşamba',
  'Perşembe',
  'Cuma',
  'Cumartesi',
  'Pazar',
];
const _shortDays = ['Pt', 'Sa', 'Ça', 'Pe', 'Cu', 'Ct', 'Pz'];

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime get today => dateOnly(DateTime.now());

String dayMonth(DateTime d) => '${d.day} ${_months[d.month - 1]}';

String shortDayMonth(DateTime d) => '${d.day} ${_shortMonths[d.month - 1]}';

String longDate(DateTime d) =>
    '${d.day} ${_months[d.month - 1]} ${_days[d.weekday - 1]}';

String shortMonth(int month) => _shortMonths[(month - 1) % 12];

String shortWeekday(DateTime d) => _shortDays[d.weekday - 1];

String hm(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

String timeAgo(DateTime t) {
  final diff = DateTime.now().difference(t);
  if (diff.inMinutes < 1) return 'az önce';
  if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
  if (diff.inHours < 24) return '${diff.inHours} sa önce';
  if (diff.inDays == 1) return 'dün';
  return '${diff.inDays} gün önce';
}

/// Bugünden [d] tarihine kalan gün (bugün = 0).
int daysUntil(DateTime d) => dateOnly(d).difference(today).inDays;

String deadlineLabel(int days) => switch (days) {
  < 0 => 'Başvuru kapandı',
  0 => 'Son başvuru bugün',
  1 => 'Son başvuru yarın',
  _ => 'Son başvuruya $days gün',
};
