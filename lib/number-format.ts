export function formatNominal(value:unknown){const digits=String(value??'').replace(/\D/g,'');return digits?new Intl.NumberFormat('id-ID').format(Number(digits)):''}
export function parseNominal(value:string){return value.replace(/\D/g,'')}
