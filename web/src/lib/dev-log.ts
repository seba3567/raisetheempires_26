/**
 * Checks whether developer/diagnostic logging is active.
 * Active in local Vite development (`NODE_ENV !== 'production'`), or if explicitly requested
 * via `?debug=1` or `localStorage.rte_debug = '1'`.
 */
export function isDebugEnabled(): boolean {
	if (typeof window === 'undefined') {
		return typeof process !== 'undefined' && process.env?.NODE_ENV !== 'production';
	}
	try {
		const params = new URLSearchParams(window.location.search);
		const isExplicitDebug = params.has('debug') || window.localStorage?.getItem('rte_debug') === '1';
		const isDevEnv =
			typeof process !== 'undefined'
				? process.env?.NODE_ENV !== 'production'
				: Boolean((import.meta as unknown as { env?: { DEV?: boolean } }).env?.DEV ?? true);

		return isExplicitDebug || isDevEnv;
	} catch {
		return true;
	}
}

export interface As3TraceEntry {
	time: string;
	message: string;
}

declare global {
	interface Window {
		__RTE_TRACES__?: As3TraceEntry[];
		rteToggleDebug?: () => boolean;
		rteToggleTraceStream?: () => boolean;
		rteShowTraces?: (count?: number) => void;
	}
}

// Expose quick helpers in console for developers
if (typeof window !== 'undefined') {
	window.rteToggleDebug = () => {
		const current = window.localStorage?.getItem('rte_debug') === '1';
		const next = !current;
		if (next) window.localStorage?.setItem('rte_debug', '1');
		else window.localStorage?.removeItem('rte_debug');
		console.log(`[RTE] Modo debug ahora está ${next ? 'ACTIVADO' : 'DESACTIVADO'}.`);
		return next;
	};

	window.rteToggleTraceStream = () => {
		const current = window.localStorage?.getItem('rte_trace_console') === '1';
		const next = !current;
		if (next) window.localStorage?.setItem('rte_trace_console', '1');
		else window.localStorage?.removeItem('rte_trace_console');
		console.log(`[RTE] Streaming en vivo de trazas AS3 ahora está ${next ? 'ACTIVADO' : 'DESACTIVADO'}.`);
		return next;
	};

	window.rteShowTraces = (count = 50) => {
		const traces = window.__RTE_TRACES__ ?? [];
		const slice = traces.slice(-count);
		console.log(`[RTE] Mostrando últimas ${slice.length} trazas AS3 (de ${traces.length} en búfer):`);
		console.table(slice);
	};
}

/**
 * Categorized, styled browser console logger for development and diagnostics.
 */
export const logDev = {
	flashVars(vars: string | Record<string, unknown>) {
		if (!isDebugEnabled()) return;
		console.groupCollapsed(
			'%c[RTE:FlashVars] Parámetros de inicialización del cliente Flash',
			'color: #38bdf8; font-weight: bold; background: #0c4a6e; padding: 2px 6px; border-radius: 4px;'
		);
		if (typeof vars === 'string') {
			try {
				const parsed = Object.fromEntries(new URLSearchParams(vars).entries());
				console.table(parsed);
				console.log('Query string raw:', vars);
			} catch {
				console.log('Raw flashVars:', vars);
			}
		} else {
			console.table(vars);
			console.log('Objeto completo raw:', vars);
		}
		console.groupEnd();
	},

	ruffle(msg: string, details?: unknown) {
		if (!isDebugEnabled()) return;
		if (details !== undefined) {
			console.log(
				`%c[RTE:Ruffle]%c ${msg}`,
				'color: #c084fc; font-weight: bold; background: #3b0764; padding: 1px 5px; border-radius: 3px;',
				'color: #e2e8f0; font-weight: normal;',
				details
			);
		} else {
			console.log(
				`%c[RTE:Ruffle]%c ${msg}`,
				'color: #c084fc; font-weight: bold; background: #3b0764; padding: 1px 5px; border-radius: 3px;',
				'color: #e2e8f0; font-weight: normal;'
			);
		}
	},

	snapi(event: string, payload?: unknown) {
		if (!isDebugEnabled()) return;
		if (payload !== undefined) {
			console.log(
				`%c[RTE:SNAPI]%c ${event}`,
				'color: #34d399; font-weight: bold; background: #064e3b; padding: 1px 5px; border-radius: 3px;',
				'color: #a7f3d0; font-weight: normal;',
				payload
			);
		} else {
			console.log(
				`%c[RTE:SNAPI]%c ${event}`,
				'color: #34d399; font-weight: bold; background: #064e3b; padding: 1px 5px; border-radius: 3px;',
				'color: #a7f3d0; font-weight: normal;'
			);
		}
	},

	as3(message: string) {
		if (typeof window === 'undefined') return;
		window.__RTE_TRACES__ = window.__RTE_TRACES__ || [];
		window.__RTE_TRACES__.push({ time: new Date().toLocaleTimeString(), message });
		if (window.__RTE_TRACES__.length > 100) {
			window.__RTE_TRACES__.shift();
		}

		// Only log synchronously to console if live streaming is explicitly requested.
		// Unconditional styled console.log on thousands of AS3 traces starves the browser UI.
		if (window.localStorage?.getItem('rte_trace_console') === '1') {
			console.log(`[AS3] ${message}`);
		}
	},

	metrics(title: string, metrics: Record<string, unknown>) {
		if (!isDebugEnabled()) return;
		console.groupCollapsed(
			`%c[RTE:Metrics] ${title}`,
			'color: #f472b6; font-weight: bold; background: #831843; padding: 1px 5px; border-radius: 3px;'
		);
		console.table(metrics);
		console.groupEnd();
	}
};
