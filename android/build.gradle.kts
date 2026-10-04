allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// ── FIX: Force compileSdk 36 BEFORE :app is evaluated ──
subprojects {
    plugins.withId("com.android.library") {
        extensions.findByName("android")?.let { ext ->
            try {
                // Modern AGP (8.x+)
                ext.javaClass.getMethod("setCompileSdk", Int::class.javaPrimitiveType).invoke(ext, 36)
            } catch (e: Exception) {
                try {
                    // Older AGP
                    ext.javaClass.getMethod("compileSdkVersion", Int::class.javaPrimitiveType).invoke(ext, 36)
                } catch (e2: Exception) {
                    println("Could not override compileSdk for ${project.name}")
                }
            }
        }
    }
    plugins.withId("com.android.application") {
        extensions.findByName("android")?.let { ext ->
            try {
                ext.javaClass.getMethod("setCompileSdk", Int::class.javaPrimitiveType).invoke(ext, 36)
            } catch (e: Exception) {
                try {
                    ext.javaClass.getMethod("compileSdkVersion", Int::class.javaPrimitiveType).invoke(ext, 36)
                } catch (e2: Exception) {}
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}