# Rancangan sistem Lembar

[README](../README.md) · [ERD](ERD.md)

## Komponen dan aliran data

```mermaid
flowchart LR
    Student --> UI["Flutter · Katalog, Detail, Lesson"]
    UI --> Router["go_router · guard sesi dan route ber-ID"]
    Router --> Session["Riverpod · sesi demo"]
    UI --> State["Riverpod · katalog dan detail"]
    State --> Repo["CourseRepository"]
    Repo --> JSON["courses.json"]
    Repo -. "adapter usulan" .-> API["API HTTPS"]
    UI --> Player{"Sumber lesson"}
    Player --> YouTube["YouTube IFrame Player"]
    Player --> MP4["video_player · MP4"]
```

| Direktori di `lib/` | Tanggung jawab |
| --- | --- |
| `app/`, `auth/` | Tema, navigasi, guard sesi, serta masuk dan keluar akun demo. |
| `courses/` | Repository memvalidasi fixture dan membentuk model. Provider Riverpod memberi UI state loading, data, kosong, error, dan retry. |
| `player/` | Layar lesson memilih pemutar dari sumber video. Panel YouTube dipakai oleh katalog demo. `VideoSession` menangani siklus hidup MP4. |
| `shared/ui/`, `l10n/` | Komponen bersama dan teks UI berbahasa Indonesia. |

## Kontrak data

[Fixture demo](../assets/data/courses.json) memuat objek `data` berisi daftar course. Setiap course memiliki `id`, `title`, `summary`, `description`, `category`, `coverKey`, dan `lessons[]`. Ini salah satu objek lesson di fixture.

```json
{
  "id": "pengantar-figma-design",
  "courseId": "dasar-desain-ui",
  "order": 1,
  "title": "Pengantar Figma Design",
  "description": "Kenali fungsi Figma dan cara mulai menggunakan akun gratis.",
  "durationSeconds": 478,
  "youtubeVideoId": "OgNq2UYpf2o",
  "youtubeChannel": "Bayu Alpiansyah"
}
```

| Metode repository | Endpoint usulan | Respons |
| --- | --- | --- |
| `listCourses()` | `GET /v1/courses` | `{"data": [...]}` dengan ringkasan course, `lessonCount`, dan `totalDurationSeconds`. Katalog kosong mengembalikan `{"data":[]}`. |
| `getCourse(courseId)` | `GET /v1/courses/{courseId}` | `{"data": {...}}` dengan deskripsi dan `lessons[]`. Course tanpa materi mengembalikan `lessons: []`. |

Untuk memakai API, implementasikan `CourseRepository` dengan adapter HTTP dan pasang melalui `courseRepositoryProvider`. Petakan 404 ke `notFound`, kegagalan koneksi atau timeout ke `offline`, 5xx ke `unavailable`, dan respons yang gagal divalidasi ke `invalidData`.

## Alur Student dan video

```mermaid
flowchart TD
    Login["Masuk dengan akun demo"] --> Catalog["Muat katalog"]
    Catalog --> Detail["Buka detail course"]
    Detail --> Choose["Pilih lesson"]
    Choose --> Valid{"Lesson terdaftar di course?"}
    Valid -->|Tidak| Detail
    Valid -->|Ya| Player["Siapkan controller untuk video aktif"]
    Player --> Ready["Putar, jeda, atau seek"]
    Player --> Error["Tampilkan pesan jika gagal"]
    Error --> Retry["Coba lagi"]
    Retry --> Close["Lepas controller lama"]
    Error --> YouTube["Buka video yang sama di YouTube"]
    Ready --> Switch["Pilih lesson lain"]
    Switch --> Close
    Close --> Player
    Ready --> Back["Kembali dan lepas controller"]
    Back --> Detail
```

Saat aplikasi tidak aktif, player dijeda. Keluar dari layar atau berganti lesson melepas controller serta langganan event lama. Pemutar YouTube memerlukan internet. Pemutar MP4 dapat menerima aset lokal atau URL HTTPS sesuai data lesson. Untuk fixture MP4, `LESSON_VIDEO_BASE_URL` dapat mengarahkan sumber ke `<base>/<lessonId>.mp4`.

## UI

Tema terang memakai latar hangat dan lime untuk aksi utama. Judul menggunakan Space Grotesk, isi menggunakan Inter, dan metadata menggunakan IBM Plex Mono. Layar memakai margin 20 dp dan lebar konten maksimum 600 dp. Pada layar pendek atau dengan teks besar, tombol utama detail ikut bergulir bersama konten. [Layar dan komponen Figma](https://www.figma.com/design/5gs2WKfTLrd0i4a5kdvDUV/Lembar-Simple-E-Learning?node-id=8-662)
