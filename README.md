# avplayer-flash
支持hls点播和直播的flash播放器<br/>

播放器支持参数如下:<br/>
url              string			hls vod or hls live地址<br/>
skinUrl          string			播放器皮肤地址<br/>
title            string			视频标题。全屏时显示在播放器上方的TopBarView<br/>
autoPlay         "true" or "1"	默认非自动播放。传入"true" or "1"，播放器自动播放<br/>
autoRewind	     "true" or "1"  默认非自动重播。传入"true" or "1"，播放器在播放结束时自动重播<br/>
debug		     "true" or "1"	默认关闭。传入"true" or "1"，播放器输出播放过程日志到CriticalLogView；点击播放器，按下Shift+L，呼出日志面板<br/>
simplifiedUI     "true" or "1"  默认使用标准UI。传入"true" or "1"，播放器使用精简版UI<br/>
disableHWAccel   "true" or "1"  默认使用硬件加速。传入"true" or "1"，播放器关闭硬件加速<br/>
poster           string         非自动播放时显示的封面图片地址<br/>

<b>How to use:</b>
    建议通过 avplayer.js(https://github.com/yangq1990/avplayer.js) 引入使用此flash播放器。