from _typeshed import Incomplete

from braintree.graphql.inputs.customer_session_input import CustomerSessionInput

class CreateCustomerSessionInput:
    def __init__(
        self,
        merchant_account_id: str | None = None,
        session_id: str | None = None,
        customer: CustomerSessionInput | None = None,
        domain: str | None = None,
    ) -> None: ...
    def to_graphql_variables(self) -> dict[Incomplete, Incomplete]: ...
    @staticmethod
    def builder(): ...

    class Builder:
        def __init__(self) -> None: ...
        def merchant_account_id(self, merchant_account_id: str): ...
        def session_id(self, session_id: str): ...
        def customer(self, customer: str): ...
        def domain(self, domain: str): ...
        def build(self): ...
