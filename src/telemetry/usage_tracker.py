class UsageTracker:
    """Telemetría básica para entender uso"""
    
    def track_event(self, event: str, properties: dict):
        # Log local (NO enviar sin permiso)
        log_entry = {
            'timestamp': time.time(),
            'event': event,
            'properties': properties
        }
        # Escribir a ~/.lynx/usage.log