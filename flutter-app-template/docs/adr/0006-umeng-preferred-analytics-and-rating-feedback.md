# 友盟优先行为埋点 + 应用内评分 / 用户反馈边界

行为埋点仍走 `Analytics` 端口与 `AppEvents`；配置了友盟双端 AppKey 时挂 `UmengAnalyticsAdapter` 并优先于 Firebase Analytics（互斥，不双写），密钥只经 `instance.config.yaml` → dart-define。友盟 init：`dev` 有 key 即可；`prod` 须 `PrivacyConsent` 已接受后再 init（`AppBindings.enableUmengAfterPrivacyConsent`），模板不做完整隐私页。评分仅提供手动 `AppRatingPrompt`（图 2 三按钮）+ `url_launcher` 商店 URL；差评进模板**用户反馈页**（Toast + 打点、无 HTTP、不上传正文）；不自动弹窗、不用系统 in-app review。
