import { db } from "./db.js"


export async function getSandboxConfig(sandboxType: string) {
    const [rows] = await db.query<any[]>(
        'SELECT image, binds, persistent FROM sandbox WHERE type = ?',
        [sandboxType]
    )
    const row = rows[0] ?? { image: 'ubuntu', binds: null }
    const config = {
        image: row.image,
        binds: typeof row.binds === 'string' ? JSON.parse(row.binds) : row.binds,
        persistent: row.persistent === 1,
    }

    if (config.binds) {
        const kubeconfig = process.env.KUBECONFIG_PATH ?? `${process.env.HOME}/.kube/config`
        config.binds = config.binds.map((b: string) => 
            b.replace('{KUBECONFIG_HOST_PATH}', kubeconfig)
        )
    }

    return config
}