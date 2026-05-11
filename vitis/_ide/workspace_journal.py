# 2026-05-10T03:13:08.747005900
import vitis

client = vitis.create_client()
client.set_workspace(path="vitis")

platform = client.create_platform_component(name = "platform",hw_design = "$COMPONENT_LOCATION/../../RV32I_PIPELINE/RV/BD_1_wrapper.xsa",os = "standalone",cpu = "psu_cortexa53_0",domain_name = "standalone_psu_cortexa53_0",architecture = "64-bit",compiler = "gcc")

comp = client.create_app_component(name="RV_IP",platform = "$COMPONENT_LOCATION/../platform/export/platform/platform.xpfm",domain = "standalone_psu_cortexa53_0")

comp = client.get_component(name="RV_IP")
comp.build()

platform = client.get_component(name="platform")
status = platform.build()

comp.build()

