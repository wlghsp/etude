package com.etude.domain.sandbox

import com.fasterxml.jackson.databind.ObjectMapper
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service

@Service
class SandboxConfigService(
    private val sandboxConfigRepository: SandboxConfigRepository,
    private val objectMapper: ObjectMapper,
    @Value("\${etude.kubeconfig-path}")
    private val kubeconfigPath: String,
) {
    fun getSandboxConfig(sandboxType: String): SandboxConfig {
        val entity = sandboxConfigRepository.findByType(sandboxType)
            ?: return SandboxConfig(image = "ubuntu", binds = null, persistent = false)

        val binds = entity.binds
            ?.let { parseBinds(it) }
            ?.map { it.replace("{KUBECONFIG_HOST_PATH}", kubeconfigPath) }

        return SandboxConfig(image = entity.image, binds = binds, persistent = entity.persistent)
    }

    private fun parseBinds(json: String): List<String> =
        objectMapper.readValue(json, Array<String>::class.java).toList()
}