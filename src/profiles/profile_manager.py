"""
Profile management system
"""

from dataclasses import dataclass
from typing import List, Dict, Optional
from PySide6.QtCore import QObject, Slot, Signal


@dataclass
class Profile:
    """Perfil de desarrollo"""

    name: str
    description: str
    tools: List[str]
    lsp_servers: Dict[str, List[str]]
    keybindings: Dict[str, str]
    theme: str
    extensions: List[str]
    custom_commands: Dict[str, str]


class ProfileManager(QObject):
    """
    Gestor de perfiles de desarrollo
    - Software Development
    - Cybersecurity
    - Network Engineering
    """

    profilesChanged = Signal()
    currentProfileChanged = Signal(str)

    def __init__(self):
        super().__init__()
        self.profiles: Dict[str, Profile] = {}
        self.current_profile: Optional[Profile] = None
        self._load_default_profiles()

    def _load_default_profiles(self):
        """Carga perfiles por defecto"""

        # Perfil: Software Development
        self.profiles["software_dev"] = Profile(
            name="Software Development",
            description="Full-stack development with LSP support",
            tools=[
                "git_integration",
                "terminal",
                "debugger",
                "task_runner",
                "docker_integration",
                "rest_client",
            ],
            lsp_servers={
                "python": ["pylsp"],
                "javascript": ["typescript-language-server", "--stdio"],
                "rust": ["rust-analyzer"],
                "cpp": ["clangd"],
                "go": ["gopls"],
            },
            keybindings={
                "Ctrl+B": "build_project",
                "F5": "start_debugging",
                "Ctrl+Shift+T": "run_tests",
                "Ctrl+`": "toggle_terminal",
            },
            theme="one_dark_pro",
            extensions=["prettier", "eslint", "black", "mypy"],
            custom_commands={
                "run_python": "python ${file}",
                "run_node": "node ${file}",
                "cargo_run": "cargo run",
            },
        )

        # Perfil: Cybersecurity
        self.profiles["cybersecurity"] = Profile(
            name="Cybersecurity",
            description="Security analysis and penetration testing",
            tools=[
                "hex_editor",
                "packet_analyzer",
                "hash_calculator",
                "base64_encoder",
                "regex_tester",
                "port_scanner",
                "vulnerability_scanner",
            ],
            lsp_servers={"python": ["pylsp"], "bash": ["bash-language-server"]},
            keybindings={
                "Ctrl+Shift+H": "open_hex_editor",
                "Ctrl+Shift+P": "analyze_packet",
                "Ctrl+Shift+X": "calculate_hash",
                "F6": "run_security_scan",
            },
            theme="monokai_dark",
            extensions=["security_linter", "cve_highlighter"],
            custom_commands={
                "nmap_scan": "nmap -sV ${target}",
                "run_metasploit": "msfconsole",
                "analyze_binary": "radare2 ${file}",
            },
        )

        # Perfil: Network Engineering
        self.profiles["network_engineer"] = Profile(
            name="Network Engineering",
            description="Network configuration and monitoring",
            tools=[
                "ssh_client",
                "telnet_client",
                "ping_tool",
                "traceroute",
                "network_monitor",
                "config_validator",
                "topology_viewer",
            ],
            lsp_servers={"python": ["pylsp"], "yaml": ["yaml-language-server"]},
            keybindings={
                "Ctrl+Shift+S": "open_ssh",
                "Ctrl+Shift+N": "network_scan",
                "F7": "validate_config",
                "Ctrl+Shift+M": "monitor_network",
            },
            theme="solarized_dark",
            extensions=["cisco_syntax", "juniper_syntax", "network_diagram"],
            custom_commands={
                "ssh_connect": "ssh ${user}@${host}",
                "ping_host": "ping -c 4 ${host}",
                "traceroute": "traceroute ${host}",
            },
        )

    @Slot(str)
    def set_profile(self, profile_name: str):
        """Cambia el perfil activo"""
        if profile_name in self.profiles:
            self.current_profile = self.profiles[profile_name]
            self.currentProfileChanged.emit(profile_name)

    @Slot(result="QVariantList")
    def get_profiles(self) -> List[Dict]:
        """Obtiene lista de perfiles para QML"""
        return [
            {"name": p.name, "description": p.description, "tools": p.tools}
            for p in self.profiles.values()
        ]
