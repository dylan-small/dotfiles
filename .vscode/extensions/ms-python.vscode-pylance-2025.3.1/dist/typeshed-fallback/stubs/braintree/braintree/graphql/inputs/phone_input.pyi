class PhoneInput:
    def __init__(
        self, country_phone_code: str | None = None, phone_number: str | None = None, extension_number: str | None = None
    ) -> None: ...
    def to_graphql_variables(self): ...
    @staticmethod
    def builder(): ...

    class Builder:
        def __init__(self) -> None: ...
        def country_phone_code(self, country_phone_code: str): ...
        def phone_number(self, phone_number: str): ...
        def extension_number(self, extension_number: str): ...
        def build(self): ...
