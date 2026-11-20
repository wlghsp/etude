import Docker from 'dockerode'

export const docker = new Docker()

export async function cleanupOrphanContainers() {
    const containers = await docker.listContainers({
        all: true,
        filters: JSON.stringify({ label: ['etude=sandbox'] }),
    })
    for (const c of containers) {
        const container = docker.getContainer(c.Id)
        await container.stop().catch(() => {})
        await container.remove({ v: true }).catch(() => {}) // v: dind 컨테이너의 익명 볼륨(/var/lib/docker)까지 지운다
    }
}

export async function cleanupRunningContainers() {
    const containers = await docker.listContainers({
        filters: JSON.stringify({ label: ['etude=sandbox'] }),
    })
    for (const c of containers) {
        const container = docker.getContainer(c.Id)
        await container.stop().catch(() => {})
        await container.remove({ v: true }).catch(() => {}) // v: dind 컨테이너의 익명 볼륨(/var/lib/docker)까지 지운다
    }
}
