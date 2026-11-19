# ERD Lembar

Model logis katalog yang dimuat dari [fixture JSON](../assets/data/courses.json) dan sesi demo dalam memori.

```mermaid
erDiagram
    COURSE ||--o{ LESSON : berisi
    STUDENT ||--o| SESSION : memiliki

    COURSE {
        string id PK
        string title
        string summary
        string description
        string category
        string coverKey
    }
    LESSON {
        string id PK
        string courseId FK
        int order
        string title
        string description
        int durationSeconds
        string youtubeVideoId
        string youtubeChannel
        string videoAsset "opsional"
        string videoUrl "opsional"
        string youtubeReferenceId "opsional"
    }
    STUDENT {
        string id PK
        string email UK
    }
    SESSION {
        string studentId FK
    }
```

- `Lesson.courseId` harus cocok dengan course induk. ID lesson unik dalam katalog. `order` positif dan unik per course. Jumlah lesson dan durasi course dihitung dari daftar lesson.
- Kesembilan lesson demo memakai `youtubeVideoId` dan menyertakan atribusi `youtubeChannel`. Repository juga mendukung sumber MP4 melalui `videoAsset` atau `videoUrl` HTTPS. `youtubeReferenceId` dapat menyimpan tautan referensi terpisah.
- Sesi direpresentasikan sebagai `Student?` dalam satu provider. Semua sesi demo mengakses katalog yang sama. Data enrollment dan progres berada di luar model demo.

[Rancangan sistem dan kontrak data](SYSTEM-DESIGN.md)
