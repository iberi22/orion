allprojects {
    repositories {
        mavenCentral()
    }

// Temporary workaround: AGP namespace requirement for isar_flutter_libs <4.0
subprojects {
    afterEvaluate {
        if (name == "isar_flutter_libs") {
            pluginManager.withPlugin("com.android.library") {
                extensions.configure<com.android.build.gradle.LibraryExtension> {
                    namespace = "dev.isar.isar_flutter_libs"
                }
            }
        }
    }
}

repositories {
        google()
        mavenCentral()
    }
}
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
