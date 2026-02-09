import org.gradle.api.tasks.Delete

rootProject.buildDir = file("../build")
subprojects {
    buildDir = file("${rootProject.buildDir}/$name")
}
subprojects {
    tasks.withType<Test>().configureEach {
        enabled = false
    }
}
subprojects {
    afterEvaluate {
        if (project.hasProperty("android")) {
            extensions.findByType(com.android.build.gradle.BaseExtension::class.java)?.apply {
                lintOptions {
                    disable("NewApi", "InlinedApi")
                    isAbortOnError = false
                }
            }
        }
    }
}
tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
