
# 图片验证码
### 使用方法如下

1. post方式访问http://xxx/restapi/v1/captchas，post可以无内容，可以传当前时间戳
默认都应该正常返回信息，例如： {"errno":0,"errmsg": "success","data":"9761c7bc4f330b439ac2c67301778839"}

2. get方式拼接url访问，例如http://xxx/restapi/v1/captchas/9761c7bc4f330b439ac2c67301778839
正常情况下或得到一个图片验证码

3. post方式访问http://xxx/restapi/v1/captchas/check ， post数据格式如：'hash=1873656651249e378ba4c2f55373702f&code=teiq'，其中hash为第一次请求时候的data，code为验证码图片内容（数字+字母共四位）
验证通过返回数据为：{"errno": 0,"errmsg": "success" }
验证失败返回信息为：{"errno": -3,"errmsg": "fail" }

注意：

* 执行第一步后获取的hash会缓存5分钟，在五分钟内执行第二步可申请验证码，验证码自申请开始有效期5分钟，重复申请会重新获得验证码
* 已做限速控制，每秒每ip最多请求5次
