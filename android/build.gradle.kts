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
        if (project.hasProperty("android")) {
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
