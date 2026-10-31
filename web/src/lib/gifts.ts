export interface GiftView {
	id: number;
	sender_id: number;
	sender_username: string;
	receiver_id: number;
	gift_type: string;
	gift_label: string;
	gift_icon: string;
	claimed: boolean;
	created_at: string;
	claimed_at: string | null;
}

export const GIFT_DEFINITIONS: Record<string, { label: string; icon: string; rewardDesc: string }> = {
	energy: { label: 'Paquete de Energía (+1)', icon: '⚡', rewardDesc: '+1 Energía' },
	coins: { label: 'Cofre de Monedas (+2.500)', icon: '🪙', rewardDesc: '+2.500 Monedas' },
	oil: { label: 'Barriles de Petróleo (+1.000)', icon: '🛢️', rewardDesc: '+1.000 Petróleo' },
	wood: { label: 'Cajas de Madera (+1.000)', icon: '🪵', rewardDesc: '+1.000 Madera' },
	blueprint: { label: 'Planos de Mejora (B01)', icon: '📐', rewardDesc: '+1 Plano Militar B01' }
};
