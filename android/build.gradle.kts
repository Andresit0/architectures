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

    afterEvaluate {
        if (project.hasProperty("android") && project.name != "app") {
            project.extensions.findByName("android")?.let { androidExt ->
                try {
                    val getNamespace = androidExt.javaClass.methods.find { it.name == "getNamespace" }
                    val hasNamespace = getNamespace?.invoke(androidExt) != null
                    if (!hasNamespace) {
                        androidExt.javaClass.methods.find {
                            it.name == "setNamespace" && it.parameterCount == 1
                        }?.invoke(androidExt, project.group.toString())
                    }
                    val getCompileSdk =
                        androidExt.javaClass.methods.find {
                            it.name == "getCompileSdk" || it.name == "getCompileSdkVersion"
                        }
                    val appSdk = project(":app").extensions.findByName("android")
                        ?.javaClass?.methods
                        ?.find { it.name == "getCompileSdk" || it.name == "getCompileSdkVersion" }
                        ?.invoke(project(":app").extensions.findByName("android"))
                    val setCompileSdk =
                        androidExt.javaClass.methods.find {
                            (it.name == "setCompileSdk" || it.name == "setCompileSdkVersion") &&
                                it.parameterCount == 1
                        }
                    if (setCompileSdk?.parameterTypes?.first() == String::class.java) {
                        setCompileSdk.invoke(androidExt, appSdk?.toString() ?: "android-36")
                    } else {
                        setCompileSdk?.invoke(androidExt, 36)
                    }
                    val javaVersion = Class.forName("org.gradle.api.JavaVersion")
                        .getMethod("toVersion", Any::class.java)
                        .invoke(null, "17") as Enum<*>
                    val compileOptions = androidExt.javaClass.methods.find {
                        it.name == "getCompileOptions"
                    }?.invoke(androidExt)
                    compileOptions?.let { co ->
                        co.javaClass.methods.find {
                            it.name == "setSourceCompatibility" && it.parameterCount == 1
                        }?.invoke(co, javaVersion)
                        co.javaClass.methods.find {
                            it.name == "setTargetCompatibility" && it.parameterCount == 1
                        }?.invoke(co, javaVersion)
                    }
                } catch (e: Exception) {
                    println("DEBUG fix failed for ${project.name}: ${e.message}")
                }
            }
            project.tasks.configureEach {
                try {
                    val kotlinOptions =
                        this.javaClass.methods.find { it.name == "getKotlinOptions" }?.invoke(this)
                    kotlinOptions?.let { ko ->
                        ko.javaClass.methods.find {
                            it.name == "setJvmTarget" && it.parameterCount == 1
                        }?.invoke(ko, "17")
                    }
                } catch (_: Exception) {
                }
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
