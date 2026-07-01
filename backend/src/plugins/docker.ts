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
        await container.remove().catch(() => {})
    }
}

export async function cleanupRunningContainers() {
    const containers = await docker.listContainers({
        filters: JSON.stringify({ label: ['etude=sandbox'] }),
    })
    for (const c of containers) {
        const container = docker.getContainer(c.Id)
        await container.stop().catch(() => {})
        await container.remove().catch(() => {})
    }
}
