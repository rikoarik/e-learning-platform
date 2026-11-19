import com.android.build.api.artifact.SingleArtifact
import com.android.build.api.variant.BuiltArtifactsLoader
import org.w3c.dom.Element
import javax.inject.Inject
import javax.xml.parsers.DocumentBuilderFactory

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseKeystore = providers.environmentVariable("ANDROID_KEYSTORE_PATH")
val releasePassword = providers.environmentVariable("ANDROID_KEYSTORE_PASSWORD")

android {
    namespace = "id.lembar.lembar"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "id.lembar.lembar"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (releaseKeystore.isPresent) {
            create("distribution") {
                storeFile = file(releaseKeystore.get())
                storePassword = releasePassword.get()
                keyAlias = "lembar-release"
                keyPassword = storePassword
                storeType = "PKCS12"
            }
        }
    }

    buildTypes {
        release {
            // Local release builds still work with the debug key when no distribution key is provided.
            signingConfig = signingConfigs.findByName("distribution") ?: signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

androidComponents {
    onVariants { variant ->
        val variantName = variant.name
        val taskSuffix = variantName.replaceFirstChar { it.uppercaseChar() }
        val namedApk = tasks.register<CopyNamedApks>("name${taskSuffix}Apks") {
            apkDirectory.set(variant.artifacts.get(SingleArtifact.APK))
            artifactLoader.set(variant.artifacts.getBuiltArtifactsLoader())
            stringsResource.set(layout.projectDirectory.file("src/main/res/values/strings.xml"))
            buildVariant.set(variantName)
            destination.set(layout.buildDirectory.dir("outputs/named-apk/$variantName"))
        }

        tasks.matching { it.name == "assemble$taskSuffix" }.configureEach {
            finalizedBy(namedApk)
        }
    }
}

abstract class CopyNamedApks @Inject constructor(
    private val files: FileSystemOperations,
) : DefaultTask() {
    @get:InputDirectory
    @get:PathSensitive(PathSensitivity.RELATIVE)
    abstract val apkDirectory: DirectoryProperty

    @get:InputFile
    @get:PathSensitive(PathSensitivity.NONE)
    abstract val stringsResource: RegularFileProperty

    @get:Input
    abstract val buildVariant: Property<String>

    @get:Internal
    abstract val artifactLoader: Property<BuiltArtifactsLoader>

    @get:OutputDirectory
    abstract val destination: DirectoryProperty

    @TaskAction
    fun copyApks() {
        val artifacts = checkNotNull(artifactLoader.get().load(apkDirectory.get())) {
            "Missing APK metadata in ${apkDirectory.get().asFile}"
        }
        val xml = DocumentBuilderFactory.newInstance().apply {
            setFeature("http://apache.org/xml/features/disallow-doctype-decl", true)
        }.newDocumentBuilder().parse(stringsResource.get().asFile)
        val strings = xml.getElementsByTagName("string")
        val label = (0 until strings.length).map { strings.item(it) as Element }
            .first { it.getAttribute("name") == "app_name" }.textContent.trim()
        val appName = label.replace(Regex("[^A-Za-z0-9._-]+"), "-").trim('-')
        check(appName.isNotEmpty()) { "app_name must contain characters suitable for a filename" }

        // Keep AGP and Flutter's original APK paths for install and tooling.
        files.sync {
            into(destination.get())
            for (apk in artifacts.elements) {
                val version = checkNotNull(apk.versionName) { "APK is missing its version name" }
                val parts = listOf(appName, version) +
                    apk.filters.map { it.identifier }.sorted() +
                    listOfNotNull(buildVariant.get().takeUnless { it == "release" })
                from(apk.outputFile) {
                    rename { parts.joinToString("-") + ".apk" }
                }
            }
        }
    }
}
