package com.etude.domain.sandbox

data class SandboxConfig(
    val image: String,
    val binds: List<String>?,
    val persistent: Boolean,
)