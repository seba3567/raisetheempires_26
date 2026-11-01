<script lang="ts">
	import { enhance } from '$app/forms';
	import { DEFAULT_AVATAR, avatarUrl } from '#lib/avatar';
	import { formatAmount } from '#lib/resources';
	import type { BattleReport } from '#lib/combat';
	import { GIFT_DEFINITIONS } from '#lib/gifts';

	let { data, form, activeTab = $bindable('friends') } = $props();
</script>

	{#if activeTab === 'gifts'}
		<div class="space-y-6">
			<div>
				<h2 class="text-xl font-bold text-white flex items-center gap-2">
					<span>🎁 Bandeja de Regalos Recibidos ({data.gifts.length})</span>
				</h2>
				<p class="text-xs text-slate-400 mt-0.5">
					Suministros reales enviados por tus aliados. Puedes reclamarlos aquí o en el juego.
				</p>
			</div>

			{#if data.gifts.length === 0}
				<div class="panel py-12 text-center space-y-3">
					<div class="text-4xl">📦</div>
					<h3 class="text-base font-semibold text-white">No tienes regalos pendientes</h3>
					<p class="text-xs text-slate-400 max-w-sm mx-auto">
						¡Pide a tus amigos que te envíen energía, monedas o planos militares para seguir construyendo tu imperio!
					</p>
				</div>
			{:else}
				<div class="grid gap-3 sm:grid-cols-2">
					{#each data.gifts as gift}
						<div class="panel border-gold-600/30 bg-gradient-to-r from-empire-900 to-empire-950 flex items-center justify-between gap-3 p-4">
							<div class="flex items-center gap-3">
								<span class="text-3xl">{gift.gift_icon}</span>
								<div>
									<div class="font-bold text-white text-sm">{gift.gift_label}</div>
									<div class="text-xs text-slate-400">
										De: <span class="text-gold-300 font-semibold">{gift.sender_username}</span> &bull; {gift.created_at}
									</div>
								</div>
							</div>

							<form method="POST" action="?/claimGift" use:enhance class="m-0">
								<input type="hidden" name="giftId" value={gift.id} />
								<button
									type="submit"
									class="btn-primary !py-1.5 !px-3 text-xs font-bold shadow"
								>
									Reclamar
								</button>
							</form>
						</div>
					{/each}
				</div>
			{/if}
		</div>
	{/if}
