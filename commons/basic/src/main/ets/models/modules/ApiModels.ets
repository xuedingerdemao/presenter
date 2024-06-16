//定义返回第一层的公共类
export class ResponseData<T> {
  code: number = 0
  msg: string = ""
  data: T | null = null
}
