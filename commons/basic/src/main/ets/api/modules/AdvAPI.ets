import { AdvertClass } from '../../models/index'
import { defaultAd } from '../../utils'


//模拟获取进入首页广告
const getAdvAPI = async () => {
  const res = await new Promise<AdvertClass>((resolve, reject) => {
    setTimeout(() => {
      resolve(defaultAd)
    }, 1000)
  })

  return res
}


export { getAdvAPI }