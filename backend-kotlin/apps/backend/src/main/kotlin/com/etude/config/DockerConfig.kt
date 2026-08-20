package com.etude.config

import com.github.dockerjava.api.DockerClient
import com.github.dockerjava.core.DockerClientImpl
import com.github.dockerjava.core.DefaultDockerClientConfig
import com.github.dockerjava.core.DockerClientConfig
import com.github.dockerjava.httpclient5.ApacheDockerHttpClient
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class DockerConfig {
    @Bean
    fun dockerClient(): DockerClient {
        val config: DockerClientConfig = DefaultDockerClientConfig.createDefaultConfigBuilder().build()
        val httpClient = ApacheDockerHttpClient.Builder()
            .dockerHost(config.dockerHost)
            .sslConfig(config.sslConfig)
            .build()
        return DockerClientImpl.getInstance(config, httpClient)
    }
}