# 区块链网络

本文从概念上描述，企业之间使用Hyperledger Fabric进行商业合作时，是如何构建区块链网络的。架构师，管理员，开发工程师，通过阅读本文，对Hyperledger Fabric主要的架构以及组件，将有更深刻的认识。本文将结合操作简易的例子，介绍区块链网络中的各大构成组件。

企业间通过建立policies对Hyperledger Fabric进行控制，根据指定的policies对网络进行升级。Policies是Hyperledger Fabric的关键功能之一，通过阅读本文，你将理解Hyperledger Fabric的主要技术组成，以及它们在企业决策中的应用。

# 区块链网络的定义

区块链网络是指为应用程序提供账本记录和智能合约(链码)服务的技术性基础设施。通常来讲，应用程序使用智能合约产生交易数据，这些交易数据有序的派发到网络中的所有节点，并写入节点自身维护的账本之中，账本的数据不可修改。应用程序的用户，或许是终端软件的使用者，或许是区块链网络的管理员。

绝大部分情况，多个企业组成联盟共同构建网络。在网络初始化之际，经过联盟的一致性决定，各个企业的权限通过policies配置设定。此外，随着时间的发展，网络的policies经过联盟的同意进行修订。下文将提及此过程。

# 目标网络

开始之前，让我们看看最终搭建的网络是什么模样吧。下图展示了目标网络的最终状态。

下图看起来相当复杂，切莫担忧，随着本文行进，每次实现当中的一小块，我们将会看到企业R1,R2,R3,R4是如何加入到网络之中，成为网络的一份子。整个网络的运转，由加入网络的企业一致同意的policies管理，例如，policies指定了谁可以添加新的企业等。接下来会看到，应用程序如何获取账本提供的数据，如何使用智能合约与网络进行交互。

![Sample Network](https://hyperledger-fabric.readthedocs.io/en/latest/_images/network.diagram.1.png)

*四个企业，R1，R2，R3，R4，达成了协议，决定共同组建一个Hyperledger Fabric网络。R4被大家推举成为网络的初始化一方，授权配置网络的初版。R4并不打算在网络中进行交易。R1和R2需要在网络中进行私密交流，R2和R3也有此诉求。企业R1的应用程序可以在channel C1中进行交易，企业R2的应用程序可以同时在channel C1和channel C2进行交易，企业R3的应用程序可以在channel C2中进行交易。节点P1维护C1的账本L1，节点P2同时维护C1的账本L1和C2的账本L2，节点P3维护C2的账本L2。网络由配置文件NC4中设定的policies进行管理，控制权归属R1和R4. Channel C1由配置文件CC1中的policies管理，控制权归属于R1和R2。Channel C2由配置文件CC2中的policies管理，控制权归属于R2和R3. O4提供ordering服务，是网络的管理节点，使用系统channel。Ordering服务同时为C1和C2的交易进行排序，打包和分发。每个企业都有各自的认证机构。*

# 创建网络

我们开始创建网络的基础部分吧。
![Basic ](https://hyperledger-fabric.readthedocs.io/en/latest/_images/network.diagram.2.png)

*网络搭建始于order的运行。在示例网络(N)中，根据网络配置文件NC4，ordering服务由单节点O4提供。NC4同时指定管理员权限归属于R4。在网络层面上，认证机构CA4用于给网络管理员以及R4的节点分配身份。*