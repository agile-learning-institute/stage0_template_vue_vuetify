import { bootstrapDevAuthFromUrl } from '@{{org.git_org}}/{{info.slug}}_spa_utils'
import { rehydrateAuthFromStorage } from '@/composables/useAuth'

bootstrapDevAuthFromUrl()
rehydrateAuthFromStorage()
