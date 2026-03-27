import { bootstrapDevAuthFromUrl } from '@agile-learning-institute/mentorhub_spa_utils'
import { rehydrateAuthFromStorage } from '@/composables/useAuth'

bootstrapDevAuthFromUrl()
rehydrateAuthFromStorage()