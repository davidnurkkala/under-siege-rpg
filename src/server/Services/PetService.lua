local PetService = {
	Priority = 0,
}

type PetService = typeof(PetService)

function PetService.PrepareBlocking(self: PetService) end

function PetService.Start(self: PetService) end

return PetService
