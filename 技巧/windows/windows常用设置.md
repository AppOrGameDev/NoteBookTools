# 我的台式机共享目录

```txt
\\10.233.100.133
username:Dell
password:Dell
```

## win10/11设置本地用户登录密码

```txt
个性化->账户->登录选项->密码->新增/更改密码
```

![](img/Snipaste_2023-10-31_08-52-21.jpg)

![](img/Snipaste_2023-10-31_08-52-51.jpg)

## win10/11本地用户开机自动登录

#### win11 不显示 **“要使用本计算机，用户必须输入用户名和密码(E)”** 解决办法

```txt
win+R --> regedit --> 进入注册表后依次展开HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PasswordLess\Device
双击打开“Device”下"DeviePasswordLessBuildVersion"将当前值十六进制的2改为0，接着点击“确定”保存注册表，并重新启动电脑。
```

![](img/Snipaste_2023-10-31_09-01-24.jpg)

```txt
重启计算机后，按“Win+R”，打开运行窗口，输入“netplwiz”或者"Control Userpasswords2"，按回车键，在出现的对话框中就可以看到“要使用本计算机，用户必须输入用户名和密码(E)”选项已经出现了
```

![](img/Snipaste_2023-10-31_09-03-11.jpg)
