
import functools
from reggen.bus_interfaces import BusProtocol
from reggen.ip_block import IpBlock

from .reg_iface_peripheral import RegIfacePeripheral
from .tlul_peripheral import TLULPeripheral


def peripheral_from_file(path: str):
    def deco_peripheral_from_file(cls):
        ip_block = IpBlock.from_path(path, [])
        if_list = ip_block.bus_interfaces.interface_list
        if len(if_list) == 0:
            raise NotImplementedError("Peripheral description without bus interface are not supported")
        if len(if_list) > 1:
            raise NotImplementedError("Peripheral decription with more than one bus interface are not supported")
        if if_list[0]["is_host"]:
            raise NotImplementedError("Only device interfaces are supported")
        if "protocol" not in if_list[0]:
            raise ValueError("Protocol not specified")
        
        proto = if_list[0]["protocol"]

        Base = None
        if proto is BusProtocol.TLUL:
            Base = TLULPeripheral
        elif proto is BusProtocol.REG_IFACE:
            Base = RegIfacePeripheral
        else:
            raise RuntimeError
        
        @functools.wraps(cls, updated=())
        class PeriphWrapper(cls, Base):
            IP_BLOCK = ip_block
            def __init__(self, domain: "str | None" = None, **kwargs):
                super().__init__(self.IP_BLOCK.name, domain, **kwargs)
                self._ip_block = self.IP_BLOCK
        
        return PeriphWrapper
    return deco_peripheral_from_file
    