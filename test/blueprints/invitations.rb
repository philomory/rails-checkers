Invitation.blueprint do
  issuer
  recipient
  first_move :random
end

Invitation.blueprint(:open) do
  recipient { nil }
end